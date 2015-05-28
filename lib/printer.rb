require 'haml'

class Printer

  def html stories
    $stories = stories
    file_path = File.expand_path('../../templates/template.html.haml', __FILE__)
    template = File.read(file_path)
    engine = Haml::Engine.new(template)
    File.write 'releasenotes.html',engine.render
  end

  def print stories
    dependencies = []

    # Github stories only
    release_notes = "PR:TITLE:ISSUES:MILESTONE\n"
    stories.each do |story|
      next if Planbox.has_planbox?(story)
      dependency = get_dependency(story)
      dependencies << "PR ##{story['number']}: " + dependency unless dependency.nil?

      line = ""
      line += github_pr_info(story) unless story['number'].nil?

      release_notes += line + "\n"
    end

    # Planbox matching stories
    if Planbox.has_planbox?(stories) 
      release_notes += title "Matched Planbox Stories"
      release_notes += "ID:STATUS:TITLE:PROJECT_NAME:PROJECT_ALIAS:PR:TITLE\n"
      stories.each do |story|
        next unless Planbox.has_planbox?(story)
        dependency = get_dependency(story)
        dependencies << "PR ##{story['number']}: " + dependency unless dependency.nil?

        line = ""
        line += planbox_info(story)
        line += github_pr_info(story) unless story['number'].nil?
      end
    end

    # print dependency blocks
    unless dependencies.empty?
      release_notes += include_dependencies dependencies
    end

    puts release_notes
  end

  def get_dependency(story)

    # find dependency based on blocks
    unless story['blocks'].nil?
      story['blocks'].each do |block|
        if block.split("\n")[0].match(/(^(#* *depend(s|ent|ency|encies|encys)))/i)
          return block
        end
      end
    end

    # find a line starting with 'depends on' in body
    if story['body']
      dependency = story['body'].match(/^(depends +on.*)/i)
      return dependency[0] if dependency
    end

    return if story['labels'].nil?
    # else find dependency based on labels
    if story['labels'].to_s.match /Has Dependency/i
      return "has a dependency label"
    end
    return nil
  end

  def planbox_info story
    "#{story['id']}:#{story['status']}:#{story['name']}:#{story['project_name']}:#{story['project_alias']}"
  end

  def github_pr_info story
    line = ":#{story['number']}:#{story['title']}"
    line += github_issue_info(story) if story['linked_issues']
    line
  end

  def github_issue_info story
    line = ""
    story['linked_issues'].each do |issue|
      line += ":ISSUE##{issue['number']}"
      line +=":Milestone #{issue['milestone']['title']}" if issue['milestone']
    end
    line
  end

  def include_dependencies dependencies
      release_notes = title "Dependencies"
      dependencies.each do |dependency|
        release_notes += dependency
        release_notes += "\n"
      end
      release_notes
  end

  def title text
    "\n---- #{text} ----\n\n"
  end
end
