require "logger"
logger = Logger.new($stdout)

task :delete_inactive_users do
  require "./lib/loader"
  user_details_gateway = Gdpr::Gateway::Userdetails.new

  Gdpr::UseCase::DeleteInactiveUsers.new(user_details_gateway:).execute
  Gdpr::UseCase::ObfuscateSponsors.new(user_details_gateway:).execute

  logger.info("Daily Inactive User Cleanup Ran")
end
