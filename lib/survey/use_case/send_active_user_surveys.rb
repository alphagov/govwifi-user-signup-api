require "logger"

class Survey::UseCase::SendActiveUserSurveys
  def initialize(user_details_gateway:, notifications_gateway:)
    @user_details_gateway = user_details_gateway
    @notifications_gateway = notifications_gateway
    @logger = Logger.new(STDOUT)
  end

  def execute
    users = user_details_gateway.fetch_active

    @logger.info("[active-users-signup-survey] sending survey to #{users.count} users.")

    users.each do |user|
      @notifications_gateway.execute(user)
    end

    user_details_gateway.mark_as_sent(users)
  end

  attr_reader :user_details_gateway, :notifications_gateway
end
