class WifiUser::UseCase::EmailJourneyHandler
  include WifiUser::EmailAllowListChecker

  def initialize(from_address:)
    @from_address = from_address
  end

  def execute
    if valid_email?(@from_address)
      user = WifiUser::User.find_or_create(contact: @from_address)
      WifiUser::EmailSender.new.send_signup_instructions(user:)
    else
      WifiUser::EmailSender.new.send_rejected_email_address(email_address: @from_address)
    end
  end
end
