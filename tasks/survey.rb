require "logger"
logger = Logger.new(STDOUT)

task :send do
  require "./lib/loader"
  #   user_details_gateway = Gdpr::Gateway::Userdetails.new
  #
  #   Gdpr::UseCase::DeleteInactiveUsers.new(user_details_gateway: user_details_gateway).execute
  #   Gdpr::UseCase::ObfuscateSponsors.new(user_details_gateway: user_details_gateway).execute

  logger.info("Daily User Cleanup Ran")
end
