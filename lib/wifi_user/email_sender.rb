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

  def self.send_sponsor_email(raw_sponsor_address, sponsee_user)
    Services.notify_client.send_email(
      email_address: sponsee_user.contact,
      template_id: sponsor_email_template_id,
      personalisation: { username: sponsee_user.username, password: sponsee_user.password, sponsor: raw_sponsor_address },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_sponsor_confirmation_plural(sponsor_address, sponsee_users)
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

  def self.send_sponsor_confirmation_singular(sponsor_address, sponsee_user)
    Services.notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_singular_template,
      personalisation: {
        contact: sponsee_user.contact,
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_sponsor_failed_confirmation_email(sponsor_address, failed_sponsees)
    Services.notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_failed_template,
      personalisation: {
        failedSponsees: failed_sponsees.map { |sponsee| "* #{sponsee.contact}" }.join("\n"),
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_followup_email(email_address)
    Services.notify_client.send_email(
      email_address:,
      template_id: followup_template_id,
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_credentials_expiring_notification(username, contact)
    Services.notify_client.send_email(
      email_address: contact,
      template_id: credentials_expiring_notification_template_id,
      personalisation: {
        username:,
        inactivity_period: "11 months",
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.notify_user(username, contact)
    Services.notify_client.send_email(
      email_address: contact,
      template_id: notify_user_template_id,
      personalisation: {
        username:,
        inactivity_period: "12 months",
      },
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def self.send_active_users_signup_survey(user)
    Services.notify_client.send_email(
      email_address: user.contact,
      template_id: active_users_signup_survey_template,
    )
  end

  def self.notify_user_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("notify_user_account_removed")
  end

  def self.credentials_expiring_notification_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("credentials_expiring_notification")
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

  def self.followup_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("followup")
  end

  def self.active_users_signup_survey_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("active_users_signup_survey")
  end
end
