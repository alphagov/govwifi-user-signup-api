require "logger"

class SmokeTests::Gateway::UserDetails
  SESSION_BATCH_SIZE = 500
  def delete_users
    logger = Logger.new(STDOUT)
    logger.info("Starting daily smoke test user deletion")

    total = 0
    loop do
      deleted_rows = DB[:userdetails].with_sql_delete("
        DELETE FROM userdetails
        WHERE contact LIKE 'govwifi-tests+%@digital.cabinet-office.gov.uk'
        AND created_at < NOW() - INTERVAL 10 MINUTE
        LIMIT #{SESSION_BATCH_SIZE}
      ")
      total += deleted_rows

      if deleted_rows.zero?
        break
      end

      logger.info("Finished daily smoke test user deletion, #{total} rows affected")
    end
  end
end
