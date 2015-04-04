require 'test_helper'

class DependencyTest < UnitTest
  describe 'dependencies' do

    describe 'show blocks' do

      it 'starting with the word dependency' do
        dependency = "Dependency\n"+
          "This is a dependency"
        story = stub_story_with_block dependency
        Printer.new.get_dependency(story).must_equal dependency
      end

      it 'starting with the word dependent' do
        dependency = "Dependent on\n"+
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
