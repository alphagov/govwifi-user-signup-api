require 'rack/test'
require 'rspec'
require 'sequel'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'


DB = Sequel.connect(
  adapter: 'mysql2',
  host: ENV.fetch('DB_HOSTNAME'),
  database: ENV.fetch('DB_NAME'),
  user: ENV.fetch('DB_USER'),
  password: ENV.fetch('DB_PASS')
)

require File.expand_path '../../app.rb', __FILE__
require File.expand_path '../../lib/user.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure { |c| c.include RSpecMixin }
