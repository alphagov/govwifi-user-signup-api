require "sequel"
require "yaml"

if ENV.key?("SENTRY_DSN")
  require "sentry-ruby"

  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.send_default_pii = true
  end
end

DB = Sequel.connect(
  adapter: "mysql2",
  host: ENV.fetch("DB_HOSTNAME"),
  database: ENV.fetch("DB_NAME"),
  user: ENV.fetch("DB_USER"),
  password: ENV.fetch("DB_PASS"),
  encoding: "utf8mb4",
)

module Common
  module Gateway; end
end

module WifiUser
  module Gateway; end

  module Repository; end

  module UseCase; end

  module Domain; end
end

module Gdpr
  module UseCase; end

  module Gateway; end
end

module Survey
  module UseCase; end

  module Gateway; end
end

module SmokeTests
  module UseCase; end

  module Gateway; end
end

require "require_all"

require_all "lib"
