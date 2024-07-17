require "logger"

class Survey::UseCase::SendActiveUserSurveys
  def self.execute
    user_details_gateway = Survey::Gateway::UserDetails.new

    users = user_details_gateway.fetch_active

    Logger.new($stdout).info("[active-users-signup-survey] sending survey to #{users.count} users.")

    users.each do |user|
      if user.mobile?
        WifiUser::SMSSender.send_active_users_signup_survey(user)
      else
        WifiUser::EmailSender.send_active_users_signup_survey(user)
      end
    end

    user_details_gateway.mark_as_sent(users)
  end

  attr_reader :user_details_gateway, :notifications_gateway
end
