require 'test_helper'

class DependencyTest < UnitTest
  describe 'dependencies' do

    describe 'show blocks' do

      match_words = %w(
        depends
        dependent
        dependency
        dependencies
        dependencys
      )

      match_words.each do |word|
        it 'starting with the word #{word}' do
          dependency = "#{word}\n"+
            "This is a dependency"
          story = stub_story_with_block dependency
          Printer.new.get_dependency(story).must_equal dependency
        end
      end

      it 'starting with the word dependent' do
        dependency = "Dependent on\n"+
          "This is a dependency"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal dependency
      end

      it 'starting with spaces then the word dependent' do
        dependency = "  Dependent on\n"+
          "This is a dependency"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal dependency
      end

      it 'with hashes and spaces at the beginning' do
        dependency = "## Dependency\n"+
          "This is a dependency"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal dependency
      end


      match_words2 = %w( depends dependent depend)
      match_words2.each do |word|
        it "starting with #{word} on" do
          dependency = "#{word} on #123"
          body = "This is a PR about things and dependencies\n#{dependency}\nmoar stuff"
          story = {'body' => body}
          Printer.new.get_dependency(story).must_equal dependency
        end
      end
    end

    describe 'dont show blocks' do
      it 'when dependent is not the first word' do
        dependency = "not Dependent\n"+
          "This is NOT a dependency"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal nil
      end

      it 'when depends is on another line of a block' do
        dependency = "## To QA:\n"+
          "depends on suff"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal nil
      end
    end

    describe 'dependency flag' do

      it 'shown when no block is found' do
        label = 'Has Dependency'
        story = {
          'labels' => [ label ]
        }
        Printer.new.get_dependency(story).must_equal "has a dependency label"
      end

      it 'not shown when a block is found' do
        dependency = "Dependency\n"+
          "This is a dependency"
        label = 'Has Dependency'
        story = stub_story_with_block dependency
        story['labels'] = [ label ]
        Printer.new.get_dependency(story).must_equal dependency
      end
    end

    def stub_story_with_block dependency
      {'blocks' => [ dependency ]}
    end
  end
end
