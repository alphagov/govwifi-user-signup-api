class WifiUser::SMSSender
  def self.send_sponsor_sms(sponsee_user)
    Services.notify_client.send_sms(
      phone_number: sponsee_user.contact,
      template_id: Notifications::NotifyTemplates.template(:credentials_sms),
      personalisation: {
        login: sponsee_user.username,
        pass: sponsee_user.password,
      },
    )
  end

  def self.send_followup_sms(contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: Notifications::NotifyTemplates.template(:followup_sms),
    )
  end

  def self.send_credentials_expiring_notification(username, contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: Notifications::NotifyTemplates.template(:credentials_expiring_notification_sms),
      personalisation: {
        username:,
        inactivity_period: "11 months",
      },
    )
  end

  def self.send_user_account_removed(_username, contact)
    Services.notify_client.send_sms(
      phone_number: contact,
      template_id: Notifications::NotifyTemplates.template(:user_account_removed_sms),
      personalisation: {
        inactivity_period: "12 months",
      },
    )
  end

  def self.send_active_users_signup_survey(user)
    Services.notify_client.send_sms(
      phone_number: user.contact,
      template_id: Notifications::NotifyTemplates.template(:active_users_signup_survey_sms),
    )
  end

  def self.send_signup_instructions(phone_number:, sms_content:, personalisation:)
    template_name = WifiUser::UseCase::SmsTemplateFinder.new.execute(sms_content:)
    Services.notify_client.send_sms(
      phone_number:,
      template_id: Notifications::NotifyTemplates.template(template_name),
      personalisation:,
    )
  end
end
