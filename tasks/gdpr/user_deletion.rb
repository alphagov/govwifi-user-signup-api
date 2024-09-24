require "logger"
logger = Logger.new($stdout)

task :delete_inactive_users do
  require "./lib/loader"
  user_details_gateway = Gdpr::Gateway::Userdetails.new

  user_details_gateway.delete_inactive_users(inactive_months: 12)
  user_details_gateway.notify_inactive_users(inactive_months: 11)
  user_details_gateway.obfuscate_sponsors

  logger.info("Daily Inactive User Cleanup Ran")
end
