require 'httparty'

PLANBOX_EMAIL=ENV['PLANBOX_EMAIL']
PLANBOX_TOKEN=ENV['PLANBOX_TOKEN']
PLANBOX_BASE_URL="https://work.planbox.com/api"

module Planbox
  include HTTParty

  def self.check_environment
    if PLANBOX_EMAIL == nil || PLANBOX_TOKEN == nil
      raise "environment variables not set. Please check that you have the following set...\
      \nPLANBOX_EMAIL\nPLANBOX_TOKEN"
    end
  end

  def self.get_release_notes pb_story_ids
    return [] if pb_story_ids.empty?
    stories = get_release_notes_array pb_story_ids
    result_string = format stories
  end

  def self.get_release_notes_array pb_story_ids
    return [] if pb_story_ids.empty?
    check_environment
    stories = get_stories pb_story_ids
  end

  def self.login
    response = self.post("#{PLANBOX_BASE_URL}/auth", { :body => {:email => PLANBOX_EMAIL, :password => PLANBOX_TOKEN}})
    self.basic_auth response['content']['access_token'], ""
  end

  def self.get_story(story_id)
    story_response = self.post("#{PLANBOX_BASE_URL}/get_story", { :body => { :story_id => story_id}})

    if story_response.parsed_response.nil? || story_response.parsed_response["code"] == "error"
      return {"id" => story_id, "name" => "story not found in planbox"}
    end

    story = story_response.parsed_response["content"]
    project_response = self.post("#{PLANBOX_BASE_URL}/get_project", { :body => { :project_id => story['project_id'], :product_id => story['product_id']}})
    project = project_response.parsed_response["content"]
    project_alias = project["alias"]
    project_name = project["name"]

    story = story.merge({"project_name" => project_name})
    story = story.merge({"project_alias" => project_alias})
    story = story.merge(
      {"pb_url" => "https://www.planbox.com/initiatives/#{story['product_id']}#story_id=#{story['id']}"})

    story
  end

  def self.get_stories(array_of_pb_ids)
    return [] if array_of_pb_ids.nil?
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

  def self.has_planbox? object
    if object.is_a?(Hash)
      return !object['name'].nil?
    elsif object.is_a?(Array)
      object.each do |story|
        return true if !story['name'].nil?
      end
      return false
    end
  end

end
