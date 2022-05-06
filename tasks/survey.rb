require "logger"
logger = Logger.new($stdout)

namespace :users_signup_survey do
  task :send_active do
    require "./lib/loader"

    logger.info("[active-users-signup-survey] starting email signup task...")

    user_details_gateway = Survey::Gateway::UserDetails.new
    notifications_gateway = Survey::Gateway::Notifications.new("active_users_signup_survey")

    Survey::UseCase::SendActiveUserSurveys.new(
      user_details_gateway:,
      notifications_gateway:,
    ).execute

    logger.info("[active-users-signup-survey] done.")
  end
end
