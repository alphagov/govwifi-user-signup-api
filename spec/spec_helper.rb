require "factory_bot"
require "rack/test"
require "rspec"
require "simplecov"
require "sequel"
require "webmock/rspec"

ENV["RACK_ENV"] = "test"

require File.expand_path "../app.rb", __dir__

module RSpecMixin
  include Rack::Test::Methods
  def app
    described_class
  end
end

SimpleCov.start
FactoryBot.find_definitions

RSpec.configure do |c|
  c.filter_run_when_matching focus: true

  c.include RSpecMixin
  c.before(:suite) do
    FactoryBot.find_definitions
  end
end
