class Gdpr::UseCase::ObfuscateSponsors
  def initialize(user_details_gateway:)
    @user_details_gateway = user_details_gateway
  end

  def execute
    user_details_gateway.obfuscate_sponsors
  end

  attr_reader :user_details_gateway
end
