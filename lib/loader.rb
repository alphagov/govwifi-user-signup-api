require 'sequel'

DB = Sequel.connect(
  adapter: 'mysql2',
  host: ENV.fetch('DB_HOSTNAME'),
  database: ENV.fetch('DB_NAME'),
  user: ENV.fetch('DB_USER'),
  password: ENV.fetch('DB_PASS')
)

module Common; end

require 'require_all'

require_all 'lib'
