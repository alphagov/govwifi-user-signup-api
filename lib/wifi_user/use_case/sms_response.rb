class WifiUser::UseCase::SmsResponse
  def initialize(user_model:, template_finder:, logger: Logger.new($stdout))
    @user_model = user_model
    @template_finder = template_finder
    @logger = logger
  end

  def execute(contact:, sms_content:)
    phone_number = WifiUser::PhoneNumber.extract_from(contact)
    return logger.warn("Unexpected contact detail found #{contact}") if phone_number.nil?

    DB.transaction do
      login_details = user_model.find_or_create(contact: phone_number)
      notify_params = { login: login_details[:username], pass: login_details[:password] }

      send_signup_instructions(phone_number, notify_params, sms_content)
    end
  rescue Notifications::Client::BadRequestError => e
    raise e unless e.message.include? "ValidationError"

    logger.warn("Failed to send email: #{e.message}")
  end

private

  attr_reader :user_model, :template_finder, :logger

  def send_signup_instructions(phone_number, login_details, sms_content)
    Services.notify_client.send_sms(
      phone_number:,
      template_id: template_finder.execute(message_content: sms_content),
      personalisation: login_details,
    )
  end
end
