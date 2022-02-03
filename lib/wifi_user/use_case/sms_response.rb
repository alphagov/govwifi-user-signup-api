class WifiUser::UseCase::SmsResponse
  def initialize(user_model:, template_finder:, logger: Logger.new($stdout))
    @user_model = user_model
    @template_finder = template_finder
    @logger = logger
  end

  def execute(contact:, sms_content:)
    phone_number = WifiUser::UseCase::ContactSanitiser.new.execute(contact)
    return logger.warn("Unexpected contact detail found #{contact}") if phone_number.nil?

    DB.transaction do
      login_details = user_model.generate(contact: phone_number)
      notify_params = { login: login_details[:username], pass: login_details[:password] }

      send_signup_instructions(phone_number, notify_params, sms_content)
    end
  rescue Notifications::Client::BadRequestError => e
    validation_errors = e.message.match("ValidationError")

    raise e unless e.message.match("ValidationError")

    logger.warn("Failed to send email: #{validation_errors}")
  end

private

  attr_reader :user_model, :template_finder, :logger

  def send_signup_instructions(phone_number, login_details, sms_content)
    client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))

    client.send_sms(
      phone_number: phone_number,
      template_id: template_finder.execute(message_content: sms_content),
      personalisation: login_details,
    )
  end
end
