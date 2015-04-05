gem 'minitest'
gem 'vcr'

require 'minitest/autorun'
require 'gplan'
require 'printer'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class UnitTest < MiniTest::Test
end
