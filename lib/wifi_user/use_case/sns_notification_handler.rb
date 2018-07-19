class WifiUser::UseCase::SnsNotificationHandler
  def initialize(logger)
    @logger = logger
  end

  def handle(request)
    payload = JSON.parse request.body.read

    logger.info(payload) if payload['Type'] == 'SubscriptionConfirmation'
    handle_email_notification(payload) if payload['Type'] == 'Notification'
    ''
  end

private

  attr_reader :logger

  def handle_email_notification(payload)
    ses_notification = JSON.parse(payload['Message'])
    return if ses_notification['mail']['messageId'] == 'AMAZON_SES_SETUP_NOTIFICATION'

    if sponsor_request?(ses_notification)
      handle_sponsor_request(ses_notification)
    else
      handle_signup_request(ses_notification)
    end
  end

  def sponsor_request?(ses_notification)
    recipient_name(ses_notification) == "sponsor"
  end

  def recipient_name(ses_notification)
    Mail::Address.new(ses_notification['mail']['commonHeaders']['to'][0]).local
  end

  def handle_signup_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    logger.info("Handling signup request from #{from_address}")

    ::WifiUser::UseCase::EmailSignup
      .new(user_model: WifiUser::Repository::User.new)
      .execute(contact: from_address)
  end

  def handle_sponsor_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    action = ses_notification['receipt']['action']

    logger.info("Handling sponsor request from #{from_address} with email #{action['objectKey']}")

    email_fetcher = Common::Gateway::S3ObjectFetcher.new(bucket: action['bucketName'], key: action['objectKey'])
    sponsee_extractor = WifiUser::UseCase::EmailSponseesExtractor.new(email_fetcher: email_fetcher)

    ::WifiUser::UseCase::SponsorUsers
      .new(user_model: WifiUser::Repository::User.new)
      .execute(sponsee_extractor.execute, from_address)
  end
end
