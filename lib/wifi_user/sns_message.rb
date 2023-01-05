class WifiUser::SnsMessage

  attr_reader :type, :message_id, :from_address, :to_address, :s3_object_key, :s3_bucket_name, :sponsor_request,
              :parsed_request, :parsed_message, :raw_from_address, :raw_to_address
  alias_method :sponsor_request?, :sponsor_request

  def initialize(body:)
    @parsed_request = JSON.parse(body)
    @parsed_message = JSON.parse(@parsed_request.fetch("Message"))

    @type = @parsed_request.fetch("Type")
    @message_id = parsed_message.fetch("mail").fetch("messageId")
    @raw_from_address = parsed_message.fetch("mail").fetch("commonHeaders").fetch("from").fetch(0)
    @from_address = Mail::Address.new(raw_from_address).address
    @raw_to_address = parsed_message.fetch("mail").fetch("commonHeaders").fetch("to").fetch(0)
    @to_address = Mail::Address.new(raw_to_address).address
    @s3_object_key = parsed_message.fetch("receipt").fetch("action").fetch("objectKey")
    @s3_bucket_name = parsed_message.fetch("receipt").fetch("action").fetch("bucketName")
    @sponsor_request = Mail::Address.new(to_address).local == "sponsor"
  end
end
