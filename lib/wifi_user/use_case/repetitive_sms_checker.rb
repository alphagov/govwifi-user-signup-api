class WifiUser::UseCase::RepetitiveSmsChecker
  NUMBER_AND_MESSAGE_MINUTES = 15
  NUMBER_AND_MESSAGE_THRESHOLD = 3

  NUMBER_MINUTES = 5
  NUMBER_THRESHOLD = 3

  CLEANUP_AFTER_MINUTES = 30

  def execute(number, message)
    cleanup

    DB[:smslog].insert number: number, message: message

    repetitive_number_and_message?(number, message) || repetitive_number?(number)
  end

private

  def repetitive_number_and_message?(number, message)
    history = DB[:smslog].where { created_at > Time.now - (NUMBER_AND_MESSAGE_MINUTES * 60) }
                         .where(number: number)
                         .where(message: message)

    history.count >= NUMBER_AND_MESSAGE_THRESHOLD
  end

  def repetitive_number?(number)
    history = DB[:smslog].where { created_at > Time.now - (NUMBER_MINUTES * 60) }
                         .where(number: number)

    history.count >= NUMBER_THRESHOLD
  end

  def cleanup
    DB[:smslog].where { created_at < Time.now - (CLEANUP_AFTER_MINUTES * 60) }
               .delete
  end
end
