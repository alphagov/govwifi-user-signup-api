# frozen_string_literal: true

module Followups
  class FollowupSender
    NUMBER_OF_DAYS_BEFORE_SENDING = 2
    HOUR = 3600
    DAY = 24 * HOUR
    def self.send_messages
      users = WifiUser::User
        .where(last_login: nil)
        .where { created_at <= (Time.now - NUMBER_OF_DAYS_BEFORE_SENDING * DAY) }
        .where(followup_sent_at: nil)
        .where { contact =~ sponsor }
      users.each do |user|
        unless user.mobile?
          WifiUser::EmailSender.send_followup_email(user.contact)
        end
        user.update(followup_sent_at: Time.now)
      end
    end
  end
end
