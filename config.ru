RACK_ENV = ENV['RACK_ENV'] ||= 'development'

if %w[production staging].include?(RACK_ENV)
  require 'raven'

  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
  end

  use Raven::Rack
end

require './app'
run App
