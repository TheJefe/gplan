require 'test_helper'

class PlanboxTest < UnitTest
  describe 'planbox' do
    it 'ids are pulled from the git log' do
      list = '[fixes #123]'
      planbox_ids = Gplan.new({}).get_ids list, PB_STORY_REGEX
      planbox_ids.first.must_equal "123"
    end

    it 'pulls multiple ids from the git log' do
      list = %q(
        [fixes #123] some commit about stuff
        [#4] Another commit about things
        Not a planbox related commit
        [done #51] Another commit about things
        [ #432 ] last commit
      )
      planbox_ids = Gplan.new({}).get_ids list, PB_STORY_REGEX
      planbox_ids.must_equal ['123','4','51','432']
    end

    it 'non planbox ids are NOT pulled from the git log' do
      list = 'commits about [] should not be picked up'
      planbox_ids = Gplan.new({}).get_ids list, PB_STORY_REGEX
      planbox_ids.count.must_equal 0
    end

  end
end
