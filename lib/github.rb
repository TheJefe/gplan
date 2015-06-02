require 'httparty'

GITHUB_USERNAME=ENV['GITHUB_USERNAME']
GITHUB_TOKEN=ENV['GITHUB_TOKEN']
GITHUB_BASE_URL="https://api.github.com"
HEADERS = {:headers => { 'User-Agent' => GITHUB_USERNAME, 'Content-Type' => 'application/json', 'Accept' => 'application/json'}}

class Github

  def check_environment
    if GITHUB_USERNAME == nil || GITHUB_TOKEN == nil
      raise "environment variables not set. Please check that you have the following set...\
      \nGITHUB_USERNAME\nGITHUB_TOKEN"
    end
  end

  def get_repo_name
    cmd = "git remote -v |grep origin"
    repo_info = `#{cmd}`
    repo_info.scan(/\:(.*\/.*)\.git/).uniq.flatten.first
  end

  def get_release_notes gh_pr_ids
    stories = get_release_notes_array gh_pr_ids
    result_string = format stories
  end

  def get_release_notes_array gh_pr_ids
    check_environment
    repo_name = get_repo_name
    get_stories repo_name, gh_pr_ids
  end

  def pulls_url(repo_name, pr_id)
    "#{GITHUB_BASE_URL}/repos/#{repo_name}/issues/#{pr_id}?access_token=#{GITHUB_TOKEN}"
  end

  def get_story(repo_name, pr_id = false)
    # if story url like "user/repo_name#123"
    unless pr_id
      story = repo_name.split '#'
      repo_name = story[0].empty? ? get_repo_name : story[0]
      pr_id = story[1]
    end
    pr = HTTParty.get( pulls_url(repo_name, pr_id), HEADERS ).parsed_response
    return {"id" => story_id, "name" => "PR not found in github"} if pr.nil? || pr["code"] == "error"
    pr = extract_linked_issues pr
    pr = extract_blocks pr
  end

  def get_stories(repo_name, array_of_pr_ids)
    stories = []
    return [] unless array_of_pr_ids
    array_of_pr_ids.each do |id|
      stories<< get_story(repo_name, id)
    end
    stories
  end

  # used to extract blocks of information from a PR body
  def extract_blocks(pr)
    body = pr['body']
    return pr if body.nil?
    blocks = body.scan(/## ?((?:(?!##).)*)/m)
    return pr if blocks.nil?

    pr['blocks'] = []
    blocks.each do |block|
      pr['blocks'] << block.first unless block.first.empty?
    end
    pr
  end

  # used to extract linked issues from the description follow githubs linking issue linking matchers
  def extract_linked_issues(pr)
    body = pr['body']
    # UGH, this happens when a story doesn't have any description
    return pr if body.nil?
    regex = /(?:close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved|connect(?:s)?(?:ed)?\s(?:to)?)\s?+((\w*\/\w*)?#(\d+))/im
    linked_issues = body.scan(regex)
    return pr if linked_issues.nil?

    pr['linked_issues'] = []
    linked_issues.each do |linked_issue|
      pr['linked_issues'] << get_story(linked_issue[0]) unless linked_issue[0].nil?
    end
    pr
  end

  # formats the output of stories
  def format(stories)
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
