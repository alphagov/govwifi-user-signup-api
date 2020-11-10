class Survey::UseCase::SendSurveys
  def initialize(user_details_gateway:, notifications_gateway:)
    @user_details_gateway = user_details_gateway
    @notifications_gateway = notifications_gateway
  end

  def execute
    users = user_details_gateway.fetch

    users.each do |user|
      @notifications_gateway.execute(user)
    end
  end

  attr_reader :user_details_gateway, :notifications_gateway
end
