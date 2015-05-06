require 'printer'
require 'github'
require 'planbox'

PB_STORY_REGEX=/\[ ?(?:fixes|done)? ?#([0-9]+) ?\]/i
GH_PR_REGEX=/Merge pull request #(\d*)/i

class Gplan

  def initialize params
    @params = params
    @repo_overide = @params.select{|i| i[/^(?!-)/]}.first
    @PRINT_HTML = @params.include? "-h"
    @gh_release_array = []
    @pb_release_array = []
    @combined = []
  end

  def generate_release_notes
    setup_repository
    list= `git log #{@target}..`

    pb_story_ids = get_ids(list, PB_STORY_REGEX)
    gh_pr_ids = get_ids(list, GH_PR_REGEX)

    @gh_release_array = Github.new.get_release_notes_array gh_pr_ids
    @pb_release_array = Planbox.get_release_notes_array pb_story_ids

    pull_pb_numbers_from_prs
    combine_results

    if @PRINT_HTML
      Printer.new.html @combined
    else
      Printer.new.print @combined
    end
  end

  def get_ids list, regex
    list.scan(regex).flatten.uniq
  end

  def combine_results
    @pb_release_array.each do |pb_story|
      @gh_release_array.each do |gh_pr|
        if gh_pr['pb_id'] and gh_pr['pb_id'].to_i == pb_story["id"]
          gh_pr.delete('id') # doing this so we don't overide the pb id
          pb_story = pb_story.merge gh_pr
          @gh_release_array.delete gh_pr
          break
        end
      end
      @combined <<  pb_story
    end

    # add the remaining unmatched PRs
    @gh_release_array.each do |gh_pr|
      @combined <<  gh_pr
    end
  end

  # used to pull story numbers from pull request titles
  def pull_pb_numbers_from_prs
    @gh_release_array.each do |gh_pr|
      pb_ids = gh_pr['title'].scan(PB_STORY_REGEX).flatten.uniq
      if !pb_ids.empty?
        gh_pr.merge!({"pb_id" => pb_ids.first.to_i}) # making an assumption that there is only 1 pb story number
      end
    end
  end

  def setup_repository
    if @repo_overide  # allow you to pass in a SHA or remote/branch to target against. This can be useful when generating release notes after a deployment
      @target = @repo_overide
    else
      conf_file =Dir.pwd+"/.gplan"
      if File.exists?(conf_file)
        File.open(conf_file, "r") do |f|
          #target should be repository/branch
          @target = f.each_line.first.chomp
        end
      end
    end
    # Set the default branch if one is not set
    @target = "production/master" unless @target
    @repo = @target.split("/").first
    begin
      `git fetch #{@repo}`
    rescue
      puts "unable to fetch #{@repo}, checking git log anyways..."
    end
  end

end
