class WifiUser::SMSSender
  def self.send_sponsor_sms(sponsee_user)
    Services.notify_client.send_sms(
      phone_number: sponsee_user.contact,
      template_id: sponsor_confirmation_credentials_template,
      personalisation: {
        login: sponsee_user.username,
        pass: sponsee_user.password,
      },
    )
  end

  def self.send_followup_sms(contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: followup_template,
    )
  end

  def self.send_credentials_expiring_notification(username, contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: credentials_expiring_notification_template,
      personalisation: {
        username:,
        inactivity_period: "11 months",
      },
    )
  end

  def self.notify_user(_username, contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: notify_user_template_id,
      personalisation: {
        inactivity_period: "12 months",
      },
    )
  end

  def self.notify_user_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_sms_template_ids").fetch("notify_user_account_removed_sms")
  end

  def self.credentials_expiring_notification_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_sms_template_ids").fetch("credentials_expiring_notification")
  end

  def self.sponsor_confirmation_credentials_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_sms_template_ids").fetch("credentials")
  end

  def self.followup_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_sms_template_ids").fetch("followup")
  end
end
