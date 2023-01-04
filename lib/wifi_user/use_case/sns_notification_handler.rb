class WifiUser::UseCase::SnsNotificationHandler
  def initialize(email_signup_handler:, sponsor_signup_handler:, logger: Logger.new($stdout))
    @email_signup_handler = email_signup_handler
    @sponsor_signup_handler = sponsor_signup_handler
    @logger = logger
  end

  def handle(payload)
    handle_email_notification(payload)
    ""
  end

private

  attr_reader :logger, :email_signup_handler, :sponsor_signup_handler

  def handle_email_notification(payload)
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
      region: "eu-west-1",
    )
    sponsee_extractor = WifiUser::UseCase::EmailSponseesExtractor.new(
      email_fetcher:,
      exclude_addresses: [from_address],
    )

    sponsor_signup_handler.execute(sponsee_extractor.execute, from_address)
  end
end
