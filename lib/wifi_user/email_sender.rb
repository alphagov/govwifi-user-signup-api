class WifiUser::EmailSender
  def self.send_rejected_email_address(email_address)
    Services.notify_client.send_email(
      email_address:,
      template_id: rejected_email_address_template_id,
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_signup_instructions(user)
    Services.notify_client.send_email(
      email_address: user.contact,
      template_id: credentials_template_id,
      personalisation: { username: user.username, password: user.password },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_sponsor_email(sponsee_user)
    Services.notify_client.send_email(
      email_address: sponsee_user.contact,
      template_id: sponsor_email_template_id,
      personalisation: { username: sponsee_user.username, password: sponsee_user.password, sponsor: sponsee_user.sponsor },
      email_reply_to_id: do_not_reply_email_address_id,
    )
    true
  rescue Notifications::Client::RequestError => e
    raise unless e.message.include?("ValidationError")

    false
  end

  def self.send_sponsor_confirmation_plural(sponsee_users)
    sponsor_address = sponsee_users.first.sponsor
    Services.notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_plural_template,
      personalisation: {
        number_of_accounts: sponsee_users.length,
        contacts: sponsee_users.map(&:contact).join("\r\n"),
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_sponsor_confirmation_singular(sponsee_user)
    Services.notify_client.send_email(
      email_address: sponsee_user.sponsor,
      template_id: sponsor_confirmation_singular_template,
      personalisation: {
        contact: sponsee_user.contact,
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_sponsor_failed_confirmation_email(failed_sponsees)
    sponsor_address = failed_sponsees.first.sponsor
    Services.notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_failed_template,
      personalisation: {
        failedSponsees: failed_sponsees.map { |sponsee| "* #{sponsee.contact}" }.join("\n"),
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.sponsor_email_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("sponsored_credentials")
  end

  def self.credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("self_signup_credentials")
  end

  def self.rejected_email_address_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("rejected_email_address")
  end

  def self.do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("do_not_reply_email_id")
  end

  def self.sponsor_confirmation_plural_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("sponsor_confirmation").fetch("plural")
  end

  def self.sponsor_confirmation_singular_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("sponsor_confirmation").fetch("singular")
  end

  def self.sponsor_confirmation_failed_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("sponsor_confirmation").fetch("failed")
  end
end
