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

  def self.sponsor_confirmation_credentials_template
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_sms_template_ids").fetch("credentials")
  end
end
