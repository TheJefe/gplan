require 'test_helper'
require 'pry'

class ReleaseNotesTest < UnitTest
  describe 'release notes' do

    before do
      github = Github.new
      @stories = []
      VCR.use_cassette("github_pull_requests") do
        @stories = github.get_release_notes_array [1,2]
      end
    end

    it 'can be printed to stdout' do
      old_stdout = $stdout
      $stdout = StringIO.new
      Printer.new.print @stories
      output = $stdout.string.split("\n")
      $stdout = old_stdout
      output.count.must_equal 12
      output.last.must_equal "PR #2: Depends on #2126 "
    end

    it 'can be printed to an html file' do
      output = Printer.new.html @stories
      output.first.must_equal "<h2>Release notes</h2>"
      output.count.must_equal 55
      assert output.to_s.include? "Depends on #2126"
    end
  end

  # Stubs to fake up repos and outputs
  class Github < Github
    def get_repo_name
      'username/repo'
    end
  end

  def File.write file, release_notes
    return release_notes.split("\n")
  end
end
