namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |_t, args|
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    db = Sequel.connect(
      adapter: "mysql2",
      host: ENV.fetch("DB_HOSTNAME"),
      database: ENV.fetch("DB_NAME"),
      user: ENV.fetch("DB_USER"),
      password: ENV.fetch("DB_PASS"),
    )
    Sequel::Migrator.run(db, "mysql/migrations", target: version)
  end
end
