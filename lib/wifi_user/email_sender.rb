class WifiUser::EmailSender
  def send_rejected_email_address(email_address:)
    Services.notify_client.send_email(
      email_address:,
      template_id: rejected_email_address_template_id,
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def send_signup_instructions(user:)
    Services.notify_client.send_email(
      email_address: user.contact,
      template_id: credentials_template_id,
      personalisation: { username: user.username, password: user.password},
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def send_sponsor_email(sponsor_address:, sponsee_user:)
    Services.notify_client.send_email(
      email_address: sponsee_user.contact,
      template_id: sponsor_email_template_id,
      template_parameters: { username: sponsee_user.username, password: sponsee_user.password, sponsor: sponsor_address },
      reply_to_id: do_not_reply_email_address_id,
    )
    true
  rescue Notifications::Client::RequestError => error
    raise unless error.message.include?("ValidationError")

    false
  end

private

  def sponsor_email_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("sponsored_credentials")
  end

  def credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("self_signup_credentials")
  end

  def rejected_email_address_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("rejected_email_address")
  end

  def do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("do_not_reply_email_id")
  end
end
