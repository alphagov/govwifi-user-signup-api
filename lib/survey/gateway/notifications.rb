require "notifications/client"

class Survey::Gateway::Notifications
  def initialize(user_model)
    @user_model = user_model
  end

  def execute
    send_survey(@user_model.contact)
  end

  private

  def send_survey(email_address)
    client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))

    client.send_email(
      email_address: email_address,
      # template_id: credentials_template_id,
      # personalisation: @user_model.generate(contact: email_address),
      # email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("self_signup_credentials")
  end
end
