require 'test_helper'

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
      output.must_equal ["PR:TITLE:ISSUES:MILESTONE", ":1: first pull request", ":2: second pull request", "", "---- Dependencies ----", "", "PR #1: Depends on #2126 ", "PR #2: Depends on #2126 "]
      output.last.must_equal "PR #2: Depends on #2126 "
    end

    it 'can be printed to an html file' do
      output = Printer.new.html @stories
      output.first.must_equal "<h2>Release notes</h2>"
      # really long string that happens to be the html that gets created
      output.must_equal ["<h2>Release notes</h2>", "<table border='1'>", "  <thead>", "    <tr>", "      <th>PR</th>", "      <th>PR Title</th>", "      <th>Issues/Milestone</th>", "      <th>Dependencies</th>", "    </tr>", "  </thead>", "  <tbody></tbody>", "  <tr>", "    <td>", "      <a href='https://github.com/username/repo/pull/1'>1</a>", "    </td>", "    <td> first pull request</td>", "    <td>", "      <table>", "        <tbody>", "        </tbody>", "      </table>", "      <td>Depends on #2126</td>", "    </td>", "  </tr>", "  <tr>", "    <td>", "      <a href='https://github.com/username/repo/pull/2'>2</a>", "    </td>", "    <td> second pull request</td>", "    <td>", "      <table>", "        <tbody>", "        </tbody>", "      </table>", "      <td>Depends on #2126</td>", "    </td>", "  </tr>", "</table>"]
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
