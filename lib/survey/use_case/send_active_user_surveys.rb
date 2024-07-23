require "logger"

class Survey::UseCase::SendActiveUserSurveys
  def self.execute(logger: Logger.new($stdout))
    user_details_gateway = Survey::Gateway::UserDetails.new

    users = user_details_gateway.fetch_active

    logger.info("[active-users-signup-survey] sending survey to #{users.count} users.")

    users.each do |user|
      if user.mobile?
        WifiUser::SMSSender.send_active_users_signup_survey(user)
      else
        WifiUser::EmailSender.send_active_users_signup_survey(user)
      end
    rescue StandardError
      logger.warn("Could not send survey to user #{user.contact}, id: #{user.id}")
    end
    user_details_gateway.mark_as_sent(users)
  end
end
