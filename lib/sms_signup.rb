class SmsSignup
  def initialize(user_model:)
    @user_model = user_model
  end

  def execute(contact:)
    phone_number = normalised_phone_number(contact)
    login_details = user_model.generate(contact: phone_number)
    notify_params = { login: login_details[:username], pass: login_details[:password] }
    send_signup_instructions(phone_number, notify_params)
  end

private

  attr_reader :user_model

  def send_signup_instructions(phone_number, login_details)
    client = Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))

    client.send_sms(
      phone_number: phone_number,
      template_id: ENV.fetch('NOTIFY_USER_SIGNUP_SMS_TEMPLATE_ID'),
      personalisation: login_details
    )
  end

  def normalised_phone_number(phone_number)
    phone_number = '44' + phone_number[1..-1] if phone_number[0..1] == '07'
    phone_number = '+' + phone_number unless phone_number[0] == '+'
    phone_number
  end
end
