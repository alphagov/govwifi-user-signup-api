require_relative 'phone_number'

class SmsResponse
  def initialize(user_model:, template_finder:)
    @user_model = user_model
    @template_finder = template_finder
  end

  def execute(contact:, sms_content:)
    phone_number = PhoneNumber.internationalise_phone_number(contact)
    login_details = user_model.generate(contact: phone_number)
    notify_params = { login: login_details[:username], pass: login_details[:password] }
    send_signup_instructions(phone_number, notify_params, sms_content)
  end

private

  attr_reader :user_model, :template_finder

  def send_signup_instructions(phone_number, login_details, sms_content)
    client = Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))

    client.send_sms(
      phone_number: phone_number,
      template_id: template_finder.execute(message_content: sms_content),
      personalisation: login_details
    )
  end
end
