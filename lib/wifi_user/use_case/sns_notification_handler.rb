class WifiUser::UseCase::SnsNotificationHandler
  def initialize(email_signup_handler:, sponsor_signup_handler:, email_parser:, logger: Logger.new(STDOUT))
    @email_signup_handler = email_signup_handler
    @sponsor_signup_handler = sponsor_signup_handler
    @logger = logger
    @email_parser = email_parser
  end

  def handle(request)
    if request_invalid?(request)
      logger.warn("Unexpected request: \n #{request.body.read}")
      return
    end
    params = request.body.read

    begin
      payload = email_parser.execute(params)
    rescue KeyError
      logger.debug("Unable to process signup.  Malformed request: #{params}")
      return
    end

    logger.info(payload) if payload.fetch(:type) == "SubscriptionConfirmation"
    handle_email_notification(payload) if payload.fetch(:type) == "Notification"
    ""
  end

private

  attr_reader :logger, :email_signup_handler, :sponsor_signup_handler, :email_parser

  def handle_email_notification(payload)
    return if payload.fetch(:message_id) == "AMAZON_SES_SETUP_NOTIFICATION"

    if sponsor_request?(payload)
      handle_sponsor_request(payload)
    else
      handle_signup_request(payload)
    end
  end

  def sponsor_request?(payload)
    Mail::Address.new(payload.fetch(:to_address)).local == "sponsor"
  end

  def handle_signup_request(payload)
    logger.debug("Handling signup request from #{payload.fetch(:from_address)}")
    email_signup_handler.execute(contact: payload.fetch(:from_address))
  end

  def handle_sponsor_request(payload)
    from_address = payload.fetch(:from_address)
    logger.debug("Handling sponsor request from #{from_address} with email #{payload.fetch(:s3_object_key)}")

    email_fetcher = Common::Gateway::S3ObjectFetcher.new(
      bucket: payload.fetch(:s3_bucket_name),
      key: payload.fetch(:s3_object_key),
    )
    sponsee_extractor = WifiUser::UseCase::EmailSponseesExtractor.new(
      email_fetcher: email_fetcher,
      exclude_addresses: [from_address],
    )

    sponsor_signup_handler.execute(sponsee_extractor.execute, from_address)
  end

  def request_invalid?(request)
    !request_valid?(request)
  end

  def request_valid?(request)
    # For now, we only care that the correct header is set to see if we're
    # actually dealing with a notification.
    # There is much more that should be in here.

    request.has_header?("HTTP_X_AMZ_SNS_MESSAGE_TYPE") \
    && request.get_header("HTTP_X_AMZ_SNS_MESSAGE_TYPE") == "Notification"
  end
end
