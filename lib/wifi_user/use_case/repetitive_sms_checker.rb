class WifiUser::UseCase::RepetitiveSmsChecker
  NUMBER_AND_MESSAGE_MINUTES = 15
  NUMBER_AND_MESSAGE_THRESHOLD = 3

  NUMBER_MINUTES = 5
  NUMBER_THRESHOLD = 10

  CLEANUP_AFTER_MINUTES = 30

  def initialize(smslog_model:)
    @smslog_model = smslog_model
  end

  def execute(number, message)
    cleanup

    return unless number

    @smslog_model.create_log(number, message)

    repetitive_number_and_message?(number, message) || repetitive_number?(number)
  end

private

  def repetitive_number_and_message?(number, message)
    history = @smslog_model.get_matching(number: number, message: message, within_minutes: NUMBER_AND_MESSAGE_MINUTES)

    history.count >= NUMBER_AND_MESSAGE_THRESHOLD
  end

  def repetitive_number?(number)
    history = @smslog_model.get_matching(number: number, within_minutes: NUMBER_MINUTES)

    history.count >= NUMBER_THRESHOLD
  end

  def cleanup
    @smslog_model.cleanup(after_minutes: CLEANUP_AFTER_MINUTES)
  end
end
