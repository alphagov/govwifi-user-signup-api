require "sensible_logging"
require "sinatra/base"
require "net/http"
require "logger"
require "./lib/loader"

class App < Sinatra::Base
  use Raven::Rack if defined? Raven
  register Sinatra::SensibleLogging

  sensible_logging(
    logger: Logger.new($stdout),
  )

  configure do
    set :log_level, Logger::DEBUG
    set :govnotify_token, ENV["GOVNOTIFY_BEARER_TOKEN"]
  end

  configure :production, :staging do
    set :dump_errors, false
  end

  configure :production do
    set :log_level, Logger::INFO
  end

  get "/healthcheck" do
    "Healthy"
  end

  post "/user-signup/email-notification" do
    if request_invalid?(request)
      logger.warn("Unexpected request: \n #{request.body.read}")
      halt 200, ""
    end

    body = request.body.read
    email_parser = WifiUser::UseCase::ParseEmailRequest.new(logger:)
    payload = email_parser.execute(body)

    halt 200, "" unless payload.fetch(:type) == "Notification"
    halt 200, "" if payload.fetch(:message_id) == "AMAZON_SES_SETUP_NOTIFICATION"
    logger.info(payload) if payload.fetch(:type) == "SubscriptionConfirmation"

    allowlist_checker = WifiUser::UseCases::CheckIfAllowlistedEmail.new(
      gateway: Common::Gateway::S3ObjectFetcher.new(
        bucket: ENV.fetch("S3_SIGNUP_ALLOWLIST_BUCKET"),
        key: ENV.fetch("S3_SIGNUP_ALLOWLIST_OBJECT_KEY"),
        region: "eu-west-2",
        ),
      )

    email_signup_handler = ::WifiUser::UseCase::EmailSignup.new(
      user_model: WifiUser::Repository::User.new,
      allowlist_checker:,
      logger:,
      )

    sponsor_signup_handler = ::WifiUser::UseCase::SponsorUsers.new(
      user_model: WifiUser::Repository::User.new,
      allowlist_checker:,
      send_sms_gateway: WifiUser::Gateway::GovNotifySMS.new,
      send_email_gateway: WifiUser::Gateway::GovNotifyEmail.new,
      logger:,
      )

    sns_message = WifiUser::SnsMessage.new(body:)
    if sns_message.sponsor_request?
      WifiUser::UseCase::SnsNotificationHandler.new(
        email_signup_handler:,
        sponsor_signup_handler:,
        logger:,
        ).handle(payload)
    else
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: sns_message.from_address).execute
    end
  rescue KeyError
    logger.debug("Unable to process signup.  Malformed request: #{body}")
    halt 200, ""
  rescue Mail::Field::ParseError => e
    logger.warn("unable to parse email address in #{@parsed_message}: #{e}")
    halt 200, ""
  end

  post "/user-signup/sms-notification/notify" do
    halt(401, "") unless is_govnotify_token_valid?

    payload = JSON.parse(request.body.read)
    source = payload["source_number"]
    destination = payload["destination_number"]
    message = payload["message"]
    logger.info("Processing SMS on /user-signup/sms-notification/notify from #{source} to #{destination} with message #{message}")

    if numbers_are_equal?(source, destination)
      logger.warn("SMS loop detected: #{destination}")
      return ""
    end

    if sender_is_repetitive?(source, message)
      logger.warn("Too many messages received from #{source} - (possible bot loop)")
      return ""
    end

    template_finder = WifiUser::UseCase::SmsTemplateFinder.new(environment: ENV.fetch("RACK_ENV"))

    WifiUser::UseCase::SmsResponse.new(
      user_model: WifiUser::Repository::User.new,
      template_finder:,
      logger:,
    ).execute(
      contact: source,
      sms_content: message,
    )
    ""
  end

  def numbers_are_equal?(number1, number2)
    contact_sanitiser = WifiUser::UseCase::ContactSanitiser.new
    contact_sanitiser.execute(number1) == contact_sanitiser.execute(number2)
  end

  def sender_is_repetitive?(source, message)
    contact_sanitiser = WifiUser::UseCase::ContactSanitiser.new
    repetitive_sms_checker = WifiUser::UseCase::RepetitiveSmsChecker.new(
      smslog_model: WifiUser::Repository::Smslog.new,
    )

    sanitised_source = contact_sanitiser.execute(source)

    repetitive_sms_checker.execute(sanitised_source, message)
  end

  def is_govnotify_token_valid?
    env.fetch("HTTP_AUTHORIZATION") == "Bearer #{settings.govnotify_token}"
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
