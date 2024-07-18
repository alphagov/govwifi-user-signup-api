require "logger"

class Gdpr::Gateway::Userdetails
  SESSION_BATCH_SIZE = 500
  DAYS_IN_YEAR = 365
  DAYS_IN_11_MONTHS = 335 # Approximation of 11 months

  def initialize
    @logger = Logger.new($stdout)
  end

  def delete_users
    @logger.info("Finding users that have been inactive for 12 months")
    inactive_users = find_inactive_users(DAYS_IN_YEAR)

    @logger.info("Found #{inactive_users.size} users that have been inactive for 12 months")

    @logger.info("Notifying users they have been removed from GovWifi")

    inactive_users.each do |user|
      username = user[:username]
      contact = user[:contact]

      if user.mobile?
        WifiUser::SMSSender.notify_user(username, contact)
      elsif user.valid_email?(contact)
        begin
          WifiUser::EmailSender.notify_user(username, contact)
        rescue Notifications::Client::BadRequestError => e
          handle_email_error(e, username, contact)
        rescue StandardError => e
          @logger.warn(e.message)
        end
      else
        @logger.warn("Invalid contact for user #{username}")
      end
    end

    @logger.info("Starting daily old user deletion")

    total = 0
    loop do
      deleted_rows = DB[:userdetails].with_sql_delete("
        DELETE FROM userdetails WHERE (last_login < DATE_SUB(NOW(), INTERVAL #{DAYS_IN_YEAR} DAY)
        OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL #{DAYS_IN_YEAR} DAY)))
        AND username != 'HEALTH'
        LIMIT #{SESSION_BATCH_SIZE}")
      total += deleted_rows

      break if deleted_rows.zero?
    end

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

  def notify_inactive_users
    @logger.info("Starting notification process for users inactive for 11 months")
    inactive_users = find_users_inactive_for_11_months(DAYS_IN_11_MONTHS)

    @logger.info("Found #{inactive_users.size} inactive users")

    inactive_users.each do |user|
      contact = user[:contact]
      username = user[:username]

      if user.mobile?
        WifiUser::SMSSender.send_credentials_expiring_notification(username, contact)
      elsif user.valid_email?(contact)
        begin
          WifiUser::EmailSender.send_credentials_expiring_notification(username, contact)
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

    @logger.info("Finished notification process for users inactive for for 11 months")
  end

private

  def find_inactive_users(days)
    WifiUser::User.where(
      Sequel.lit("
      (last_login < DATE_SUB(NOW(), INTERVAL ? DAY)
      OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL ? DAY)))
      AND username != 'HEALTH'", days, days),
    ).all
  end

  def find_users_inactive_for_11_months(days)
    WifiUser::User.where(
      Sequel.lit("
      (DATE(last_login) = DATE_SUB(CURDATE(), INTERVAL ? DAY)
      OR (last_login IS NULL AND DATE(created_at) = DATE_SUB(CURDATE(), INTERVAL ? DAY)))
      AND username != 'HEALTH'", days, days),
    ).all
  end

  def handle_email_error(error, username, contact)
    if error.message.include? "ValidationError"
      @logger.warn("Failed to send email to #{username} at #{contact}: #{error.message}")
    else
      @logger.error("Unexpected error sending email to #{username} at #{contact}: #{error.message}")
    end
  end
end
