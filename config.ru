RACK_ENV = ENV['RACK_ENV'] ||= 'development'

if %w[production staging].include?(RACK_ENV)
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
  end

  use Raven::Rack
end

require 'sequel'

DB = Sequel.connect(
  adapter: 'mysql2',
  host: ENV.fetch('DB_HOSTNAME'),
  database: ENV.fetch('DB_NAME'),
  user: ENV.fetch('DB_USER'),
  password: ENV.fetch('DB_PASS')
)

require './app'
run App
