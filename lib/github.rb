require 'httparty'

GITHUB_USERNAME=ENV['GITHUB_USERNAME']
GITHUB_TOKEN=ENV['GITHUB_TOKEN']
GITHUB_BASE_URL="https://api.github.com"
HEADERS = {:headers => { 'User-Agent' => GITHUB_USERNAME, 'Content-Type' => 'application/json', 'Accept' => 'application/json'}}

module Github
  include HTTParty

  @repo_name
  @app_name

  def self.check_environment
    if GITHUB_USERNAME == nil || GITHUB_TOKEN == nil
      raise "environment variables not set. Please check that you have the following set...\
      \nGITHUB_USERNAME\nGITHUB_TOKEN"
    end
  end

  def self.set_repo_info
    cmd = "git remote -v |grep origin"
    repo_info = `#{cmd}`
    @repo_name = repo_info.scan(/\:(.*)\//).uniq.flatten.first
    @app_name = repo_info.scan(/\/(.*)\.git/).uniq.flatten.first
  end

  def self.get_release_notes gh_pr_ids
    stories = get_release_notes_array gh_pr_ids
    result_string = format stories
  end

  def self.get_release_notes_array gh_pr_ids
    check_environment
    set_repo_info
    get_stories gh_pr_ids
  end

  def self.pulls_url(pr_id)
    "#{GITHUB_BASE_URL}/repos/#{@repo_name}/#{@app_name}/pulls/#{pr_id}?access_token=#{GITHUB_TOKEN}"
  end

  def self.get_story(pr_id)
    pr = self.get( pulls_url(pr_id), HEADERS ).parsed_response
    return {"id" => story_id, "name" => "PR not found in github"} if pr.nil? || pr["code"] == "error"
    pr = extract_blocks pr
  end

  def self.get_stories(array_of_pr_ids)
    stories = []
    return [] unless array_of_pr_ids
    array_of_pr_ids.each do |id|
      stories<< get_story(id)
    end
    stories
  end

  # formats the output of stories
  def self.format(stories)
    result_string = ""
    stories.each do |story|
      result_string += "#{story['number']}:"
      result_string += "#{story['title']}"
      result_string += "\n"
    end

    # clean up any troublesome chars
    result_string.gsub!('`', ' ') || result_string
  end

end
