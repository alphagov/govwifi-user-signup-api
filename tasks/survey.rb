require "logger"
logger = Logger.new(STDOUT)

task :send_active_users_signup_survey do
  require "./lib/loader"

  logger.info("[active-users-signup-survey] starting email signup task...")

  user_details_gateway = Survey::Gateway::UserDetails.new
  notifications_gateway = Survey::Gateway::Notifications.new

  Survey::UseCase::SendSurveys.new(
    user_details_gateway: user_details_gateway,
    notifications_gateway: notifications_gateway,
  ).execute

  logger.info("[active-users-signup-survey] done.")
end
