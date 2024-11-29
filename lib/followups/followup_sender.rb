# frozen_string_literal: true

require "logger"

module Followups
  class FollowupSender
    NUMBER_OF_DAYS_BEFORE_SENDING = 2
    HOUR = 3600
    DAY = 24 * HOUR
    def self.send_messages
      logger = Logger.new($stdout)
      logger.info("Starting followup sender task.")
      users = WifiUser::User
        .where(last_login: nil)
        .where { created_at <= (Time.now - NUMBER_OF_DAYS_BEFORE_SENDING * DAY) }
        .where(followup_sent_at: nil)
        .where { contact =~ sponsor }
      logger.info "There are #{users.count} users that did not manage to sign up"
      users.each do |user|
        unless user.mobile?
          WifiUser::EmailSender.send_followup_email(user.contact)
        end
        user.update(followup_sent_at: Time.now)
      end
      logger.info("Finished followup sender.")
    end
  end
end
