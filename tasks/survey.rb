require "logger"
logger = Logger.new(STDOUT)

namespace :users_signup_survey do
  task :send_active do
    require "./lib/loader"

    logger.info("[active-users-signup-survey] starting email signup task...")

    user_details_gateway = Survey::Gateway::UserDetails.new
    notifications_gateway = Survey::Gateway::Notifications.new("active_users_signup_survey")

    Survey::UseCase::SendActiveUserSurveys.new(
      user_details_gateway: user_details_gateway,
      notifications_gateway: notifications_gateway,
    ).execute

    logger.info("[active-users-signup-survey] done.")
  end

  task :send_inactive do
    require "./lib/loader"

    logger.info("[inactive-users-signup-survey] starting email signup task...")

    user_details_gateway = Survey::Gateway::UserDetails.new
    notifications_gateway = Survey::Gateway::Notifications.new("inactive_users_signup_survey")

    Survey::UseCase::SendInactiveUserSurveys.new(
      user_details_gateway: user_details_gateway,
      notifications_gateway: notifications_gateway,
    ).execute

    logger.info("[inactive-users-signup-survey] done.")
  end
end
