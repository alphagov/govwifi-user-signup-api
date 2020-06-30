class WifiUser::UseCase::ParseEmailRequest
  def initialize(logger: Logger.new(STDOUT))
    @logger = logger
  end

  def execute(request)
    parsed_request = JSON.parse(request)
    parsed_message = JSON.parse(parsed_request.fetch("Message"))
    logger.debug("Processing request: #{parsed_request} with message #{parsed_message}")

    {
      type: parsed_request.fetch("Type"),
      message_id: message_id(parsed_message),
      from_address: from_address(parsed_message),
      to_address: to_address(parsed_message),
      s3_object_key: s3_object_key(parsed_message),
      s3_bucket_name: s3_bucket_name(parsed_message)
    }
  end

private

  attr_reader :logger

  def message_id(request)
    request.fetch("mail").fetch("messageId")
  end

  def from_address(request)
    request.fetch("mail").fetch("commonHeaders").fetch("from").fetch(0)
  end

  def to_address(request)
    request.fetch("mail").fetch("commonHeaders").fetch("to").fetch(0)
  end

  def s3_object_key(request)
    request.fetch("receipt").fetch("action").fetch("objectKey")
  end

  def s3_bucket_name(request)
    request.fetch("receipt").fetch("action").fetch("bucketName")
  end
end
