require "notifications/client"

class Survey::Gateway::Notifications
  def initialize
    @client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
  end

  def execute(user)
    send_survey(user)
  end

private

  def send_survey(user)
    if is_mobile? user
      send_text(user)
    else
      send_email(user)
    end
  end

  def send_email(user)
    @client.send_email(
      email_address: user.contact,
    )
  end

  def send_text(user)
    @client.send_sms(
      phone_number: user.contact,
    )
  end

  def is_mobile?(user)
    user.contact.start_with? "+"
  end
end
