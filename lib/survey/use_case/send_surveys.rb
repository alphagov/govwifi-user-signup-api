require "logger"

class Survey::UseCase::SendSurveys
  def initialize(user_details_gateway:, notifications_gateway:)
    @user_details_gateway = user_details_gateway
    @notifications_gateway = notifications_gateway
    @logger = Logger.new(STDOUT)
  end

  def execute
    users = user_details_gateway.fetch

    @logger.info("[active-users-signup-survey] sending email to #{users.count} users.")

    users.each do |user|
      @notifications_gateway.execute(user)
    end
  end

  attr_reader :user_details_gateway, :notifications_gateway
end
