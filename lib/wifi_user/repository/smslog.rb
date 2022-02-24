class WifiUser::Repository::Smslog < Sequel::Model(:smslog)
  def create_log(number, message)
    self.class.insert number: number, message: message
  end

  def get_matching(number:, within_minutes:, message: nil)
    query = self.class.where { created_at > Time.now - (within_minutes * 60) }
                      .where(number:)
    query = query.where(message:) if message

    query
  end

  def cleanup(after_minutes:)
    self.class.where { created_at < Time.now - (after_minutes * 60) }
              .delete
  end
end
