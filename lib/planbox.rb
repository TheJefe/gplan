require 'httparty'

EMAIL=ENV['PLANBOX_EMAIL']
TOKEN=ENV['PLANBOX_TOKEN']
BASE_URL="https://www.planbox.com/api"

module Planbox
  include HTTParty

  def self.check_environment
    if EMAIL == nil || TOKEN == nil
      raise "environment variables not set. Please check that you have the following set...\
      \nPLANBOX_EMAIL\nPLANBOX_TOKEN"
    end
  end

  def self.get_release_notes pb_story_ids
    check_environment
    #cleaned_results = clean pb_story_ids
    stories = get_stories pb_story_ids
    result_string = format stories
  end

  def self.login
    response = self.post("#{BASE_URL}/login", { :body => {:email => EMAIL, :password => TOKEN}})
    cookie = HTTParty::CookieHash.new
    cookie.add_cookies(response.headers["set-cookie"])
    self.cookies(cookie)
  end

  def self.get_story(story_id)
    story_response = self.post("#{BASE_URL}/get_story", { :body => { :story_id => story_id}})
    return story_response.parsed_response["content"] unless story_response.parsed_response.nil? || story_response.parsed_response["code"] == "error"
    {"id" => story_id, "name" => "story not found in planbox"}
  end

  def self.get_stories(array_of_pb_ids)
    login
    stories = []
    return [] unless array_of_pb_ids
    array_of_pb_ids.each do |id|
      stories<< get_story(id)
    end
    stories
  end

  # formats the output of stories
  def self.format(stories)
    result_string = ""
    stories.each do |story|
      result_string += "#{story['id']}:"
      result_string += "#{story['status']}: "
      result_string += "#{story['name']}"
      result_string += "\n"
    end

    # clean up any troublesome chars
    result_string.gsub!('`', ' ') || result_string
  end

  # cleans up the results
  # depricated
  def self.clean( results )
    results.each do |i|
      i.gsub!('fixes', '') || i
      i.gsub!('Fixes', '') || i
      i.gsub!(' ', '') || i
      i.gsub!('[', '') || i
      i.gsub!('#', '') || i
      i.gsub!(']', '') || i
    end
    results.uniq
  end

end
