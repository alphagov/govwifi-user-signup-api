module Notifications
  class NotifyTemplates
    TEMPLATES = %w[self_signup_credentials_email
                   rejected_email_address_email
                   sponsor_credentials_email
                   sponsor_confirmation_plural_email
                   sponsor_confirmation_singular_email
                   sponsor_confirmation_failed_email
                   active_users_signup_survey_email
                   followup_email
                   credentials_expiring_notification_email
                   notify_user_account_removed_email
                   sponsor_credentials_sms].freeze

    def self.template_hash
      @template_hash ||= begin
        all_templates = Services.notify_client.get_all_templates.collection.inject({}) do |result, template|
          result.merge(template.name => template.id)
        end
        all_templates.slice(*TEMPLATES)
      end
    end

    def self.template(name)
      template_hash.fetch(name.is_a?(Symbol) ? name.to_s : name)
    end
  end
end
