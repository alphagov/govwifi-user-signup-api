require "logger"

class SmokeTests::Gateway::UserDetails
  SESSION_BATCH_SIZE = 500
  def delete_users
    logger = Logger.new($stdout)
    logger.info("Starting daily smoke test user deletion")

    total = 0
    while (rows_to_delete = get_batch).count.positive?
      total += rows_to_delete.delete
    end

    logger.info("Finished daily smoke test user deletion, #{total} rows affected")
  end

private

  def get_batch
    WifiUser::Repository::User
      .where { contact.like "govwifi-tests+%@digital.cabinet-office.gov.uk" }
      .where { created_at < Time.now - (10 * 60) }
      .limit(SESSION_BATCH_SIZE)
  end
end
