class Gdpr::UseCase::NotifyInactiveUsers
  def initialize(user_details_gateway:)
    @user_details_gateway = user_details_gateway
  end

  def execute
    user_details_gateway.notify_inactive_users
  end

  attr_reader :user_details_gateway
end
