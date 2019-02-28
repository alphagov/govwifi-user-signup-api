class WifiUser::UseCase::ParseEmailRequest
  def initialize(logger: Logger.new(STDOUT))
    @logger = logger
  end

  def execute(request)
    parsed_request = JSON.parse(request)
    parsed_message = JSON.parse(parsed_request.fetch('Message'))
    logger.debug("Processing request: #{parsed_request} with message #{parsed_message}")

    {
      type: parsed_request['Type'],
      message_id: parsed_message['mail']['messageId'],
      from_address: parsed_message['mail']['commonHeaders']['from'][0],
      to_address: parsed_message['mail']['commonHeaders']['to'][0],
      s3_object_key: parsed_message['receipt']['action']['objectKey'],
      s3_bucket_name: parsed_message['receipt']['action']['bucketName']
    }
  end

private

  attr_reader :logger
end
