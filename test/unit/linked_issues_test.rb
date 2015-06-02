require 'test_helper'

class LinkedIssuesTest < UnitTest
  describe 'linked issues' do

    let(:github) {
      gh = Github.new
      # Stub out get_story because that isn't what we want to test here
      def gh.get_story(repourl)
        return {'number' => repourl.scan(/[0-9]+/).first.to_i}
      end
      gh
    }

    match_words = %w(
        close
        closes
        closed
        fix
        fixes
        fixed
        resolve
        resolves
        resolved
        connect
        connects
        connected
        connect\ to
        connects\ to
        connected\ to
    )

    match_words.each do |word|
      it "finds linked issues based on '#{word}" do
        linked_issue_number = rand(1000)
        @body = "#{word} thejefe/gplan##{linked_issue_number}"
        pr = stub_pr(@body)
        new_pr = github.extract_linked_issues(pr)
        new_pr['linked_issues'].first['number'].must_equal linked_issue_number
      end
    end

    def stub_pr(body)
      { 'body' => body }
    end
  end
end
