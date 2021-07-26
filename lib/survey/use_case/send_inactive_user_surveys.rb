require "logger"

class Survey::UseCase::SendInactiveUserSurveys
  def initialize(user_details_gateway:, notifications_gateway:)
    @user_details_gateway = user_details_gateway
    @notifications_gateway = notifications_gateway
    @logger = Logger.new($stdout)
  end

  def execute
    users = user_details_gateway.fetch_inactive

    @logger.info("[inactive-users-signup-survey] sending survey to #{users.count} users.")

    users.each do |user|
      @notifications_gateway.execute(user)
    end

    user_details_gateway.mark_as_sent(users)
  end

  attr_reader :user_details_gateway, :notifications_gateway
end
