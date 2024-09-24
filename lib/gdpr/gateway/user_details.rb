require "logger"

class Gdpr::Gateway::Userdetails
  SESSION_BATCH_SIZE = 500

  def initialize
    @logger = Logger.new($stdout)
  end

  def delete_inactive_users(inactive_months: 12)
    @logger.info("Finding users that have been inactive for #{inactive_months} months")
    inactive_users = users_to_delete(inactive_months:)

    @logger.info("Found #{inactive_users.count} users that have been inactive for 12 months")

    @logger.info("Notifying users they have been removed from GovWifi")

    inactive_users.each do |user|
      username = user[:username]
      contact = user[:contact]

      begin
        if user.mobile?
          WifiUser::SMSSender.send_user_account_removed(contact, inactive_months)
        else
          WifiUser::EmailSender.send_user_account_removed(contact, inactive_months)
        end
      rescue Notifications::Client::BadRequestError => e
        handle_email_error(e, username, contact)
      rescue StandardError => e
        @logger.warn(e.message)
      end
    end

    @logger.info("Starting daily old user deletion")

    total = inactive_users.delete

    @logger.info("Finished daily old user deletion, #{total} rows affected")
  end

  def obfuscate_sponsors
    DB.run("
      UPDATE userdetails ud1
      LEFT JOIN userdetails as ud2 ON ud1.sponsor = ud2.contact
      SET ud1.sponsor = REPLACE(ud1.sponsor, SUBSTRING_INDEX(ud1.sponsor, '@', '1'), 'user')
      WHERE ud2.username IS NULL
    ")
  end

  def notify_inactive_users(inactive_months: 11)
    @logger.info("Starting notification process for users inactive for #{inactive_months} months")
    users = inactive_users(inactive_months:)

    @logger.info("Found #{users.size} inactive users")

    users.each do |user|
      contact = user[:contact]
      username = user[:username]

      if user.mobile?
        WifiUser::SMSSender.send_credentials_expiring_notification(username, contact, inactive_months)
      elsif user.valid_email?(contact)
        begin
          WifiUser::EmailSender.send_credentials_expiring_notification(username, contact, inactive_months)
          @logger.info("Email sent to #{username} at #{contact}")
        rescue Notifications::Client::BadRequestError => e
          handle_email_error(e, username, contact)
        rescue StandardError => e
          @logger.warn(e.message)
        end
      else
        @logger.warn("Invalid contact for user #{username}")
      end
    end

    @logger.info("Finished notification process for users inactive for for #{inactive_months} months")
  end

private

  def users_to_delete(inactive_months:)
    date_before = Date.today << inactive_months
    WifiUser::User.where(
      Sequel.lit("
      (date(last_login) <= ? OR (last_login IS NULL AND date(created_at) <= ?))
        AND username != 'HEALTH'", date_before, date_before),
    )
  end

  def inactive_users(inactive_months:)
    date_before = Date.today << inactive_months
    WifiUser::User.where { date(last_login) =~ date_before }.exclude { username =~ "HEALTH" }.all
  end

  def handle_email_error(error, username, contact)
    if error.message.include? "ValidationError"
      @logger.warn("Failed to send email to #{username} at #{contact}: #{error.message}")
    else
      @logger.error("Unexpected error sending email to #{username} at #{contact}: #{error.message}")
    end
  end
end
