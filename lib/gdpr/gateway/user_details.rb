require "logger"

class Gdpr::Gateway::Userdetails
  SESSION_BATCH_SIZE = 500
  def delete_users
    logger = Logger.new($stdout)

    logger.info("Finding users that have been inactive for 12 months")
    inactive_users = DB[:userdetails].select(:username, :contact).where(
      Sequel.lit("
      (last_login < DATE_SUB(NOW(), INTERVAL 12 MONTH)
      OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL 12 MONTH)))
      AND username != 'HEALTH'
      "),
    ).all

    logger.info("Found #{inactive_users.size} users that have been inactive for 12 months")

    logger.info("Notifying user they have been removed from GovWifi")
    inactive_users.each do |user|
      username = user[:username]
      contact = user[:contact]

      if contact.start_with?("+")
        WifiUser::SMSSender.notify_user(username, contact)
        logger.info("sms sent to #{username}: #{contact}")
      else
        WifiUser::EmailSender.notify_user(username, contact)
        logger.info("email sent to #{username}: #{contact}")
      end
    end

    logger.info("Starting daily old user deletion")

    total = 0
    loop do
      deleted_rows = DB[:userdetails].with_sql_delete("
        DELETE FROM userdetails WHERE (last_login < DATE_SUB(NOW(), INTERVAL 12 MONTH)
        OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL 12 MONTH)))
        AND username != 'HEALTH'
        LIMIT #{SESSION_BATCH_SIZE}")
      total += deleted_rows

      if deleted_rows.zero?
        break
      end
    end

    logger.info("Finished daily old user deletion, #{total} rows affected")
  end

  def obfuscate_sponsors
    DB.run("UPDATE userdetails ud1
        LEFT JOIN userdetails as ud2 ON ud1.sponsor = ud2.contact
        SET ud1.sponsor = REPLACE(ud1.sponsor, SUBSTRING_INDEX(ud1.sponsor, '@', '1'), 'user')
        WHERE ud2.username IS NULL")
  end

  def notify_inactive_users
    logger = Logger.new($stdout)
    logger.info("Starting notification process for users inactive for 11 months")

    inactive_users = DB[:userdetails].select(:username, :contact).where(
      Sequel.lit("
      (last_login < DATE_SUB(NOW(), INTERVAL 11 MONTH)
      OR (last_login IS NULL AND created_at < DATE_SUB(NOW(), INTERVAL 11 MONTH)))
      AND username != 'HEALTH'
      "),
    ).all

    logger.info("Found #{inactive_users.size} inactive users")

    inactive_users.each do |user|
      contact = user[:contact]
      username = user[:username]

      if contact.start_with?("+")
        WifiUser::SMSSender.send_credentials_expiring_notification(username, contact)
      else
        WifiUser::EmailSender.send_credentials_expiring_notification(username, contact)
      end
    end

    logger.info("Finished notification process for users inactive for 11 months")
  end
end
