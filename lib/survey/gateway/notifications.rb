require "notifications/client"

class Survey::Gateway::Notifications
  def initialize(key)
    @client = Services.notify_client

    config = YAML.load_file("config/#{ENV['RACK_ENV']}.yml")

    @email_template_id = config["notify_email_template_ids"][key]
    @mobile_template_id = config["notify_sms_template_ids"][key]
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
      template_id: @email_template_id,
    )
  end

  def send_text(user)
    @client.send_sms(
      phone_number: user.contact,
      template_id: @mobile_template_id,
    )
  end

  def is_mobile?(user)
    user.contact.start_with? "+"
  end
end
