require "logger"
logger = Logger.new($stdout)

task :delete_smoke_test_users do
  require "./lib/loader"
  user_details_gateway = SmokeTests::Gateway::UserDetails.new

  SmokeTests::UseCase::DeleteSmokeTestUsers.new(user_details_gateway: user_details_gateway).execute

  logger.info("Daily Smoke Test User Cleanup Ran")
end
