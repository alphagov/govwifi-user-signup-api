require "notifications/client"

class Survey::Gateway::Notifications
  def initialize(user_model)
    @user_model = user_model
    @client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
  end

  def execute
    send_survey
  end

private

  def send_survey
    if is_mobile?
      send_text
    else
      send_email
    end
  end

  def send_email
    @client.send_email(
      email_address: @user_model.contact,
    )
  end

  def send_text
    @client.send_sms(
      phone_number: @user_model.contact,
    )
  end

  def is_mobile?
    @user_model.contact.start_with? "+"
  end
end
