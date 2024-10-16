require "logger"
logger = Logger.new($stdout)

namespace :users_signup_survey do
  task :send_active do
    require "./lib/loader"

    logger.info("[active-users-signup-survey] starting email signup task...")

    Survey::UseCase::SendActiveUserSurveys.execute

    logger.info("[active-users-signup-survey] done.")
  end
end
