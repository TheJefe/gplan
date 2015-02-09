module Printer
  def print stories
    end_of_pbs = false
    release_notes = "ID:STATUS:TITLE:PROJECT_NAME:PROJECT_ALIAS:PR:TITLE\n"
    dependencies = []
    stories.each do |story|
      if !end_of_pbs and story['name'].nil?
        end_of_pbs = true
        release_notes += "\n---- Unmatched PRs ----\n\n"
        release_notes += "PR:TITLE\n"
      end

      dependency = pull_dependency(story)
      dependencies << dependency unless dependency.nil?

      line = ""
      line += "#{story['id']}:#{story['status']}:#{story['name']}:#{story['project_name']}:#{story['project_alias']}" unless end_of_pbs
      line += ":#{story['number']}:#{story['title']}" unless story['number'].nil?
      release_notes += line + "\n"
    end

    # print dependency blocks
    unless dependencies.empty?
      release_notes += "\n---- Dependencies ----\n\n"
      dependencies.each do |dependency|
        release_notes += dependency
        release_notes += "\n"
      end
    end

    puts release_notes
  end
end
