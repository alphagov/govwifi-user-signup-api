# frozen_string_literal: true

module Followups
  class FollowupSender
    DAYS_BEFORE_SENDING = 2
    def self.send_messages
      users = WifiUser::User
        .where(last_login: nil)
        .where { created_at <= (Date.today - DAYS_BEFORE_SENDING) }
        .where(followup_sent_at: nil)
        .where { contact =~ sponsor }
      users.each do |user|
        if user.mobile?
          WifiUser::SMSSender.send_followup_sms(user.contact)
        else
          WifiUser::EmailSender.send_followup_email(user.contact)
        end
        user.update(followup_sent_at: Time.now)
      end
    end
  end
end
