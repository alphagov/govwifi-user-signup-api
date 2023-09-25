require "logger"

class Gdpr::Gateway::Userdetails
  SESSION_BATCH_SIZE = 500
  def delete_users
    logger = Logger.new($stdout)
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
end
