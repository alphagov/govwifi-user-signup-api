class Survey::UseCase::SendSurveys
  def initialize(user_details_gateway:)
    @user_details_gateway = user_details_gateway
  end

  def execute
    p "HELLO!"
  end

  attr_reader :user_details_gateway
end
