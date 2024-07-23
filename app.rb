require "sensible_logging"
require "sinatra/base"
require "net/http"
require "logger"
require "mail"
require "notifications/client"
require "./lib/loader"

class App < Sinatra::Base
  if ENV.key?("SENTRY_DSN")
    use Sentry::Rack::CaptureExceptions
  end

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
    raise "Unexpected request: \n #{request.body.read}" if request_invalid?(request)

    sns_message = WifiUser::SnsMessage.new(body: request.body.read)

    halt 200, "" if sns_message.type != "Notification" || sns_message.message_id == "AMAZON_SES_SETUP_NOTIFICATION"
    logger.info(sns_message.to_s) if sns_message.type == "SubscriptionConfirmation"

    if sns_message.sponsor_request?
      WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
    else
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: sns_message.from_address).execute
    end
  rescue Notifications::Client::RequestError => e
    logger.error(e.message)
    raise
  rescue StandardError => e
    logger.warn(e.message)
  ensure
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
    elsif sender_is_repetitive?(source, message)
      logger.warn("Too many messages received from #{source} - (possible bot loop)")
    else
      WifiUser::UseCase::SmsResponse.new(logger:).execute(
        contact: source,
        sms_content: message,
      )
    end

    ""
  end

  def numbers_are_equal?(number1, number2)
    WifiUser::PhoneNumber.internationalise(number1) == WifiUser::PhoneNumber.internationalise(number2)
  end

  def sender_is_repetitive?(source, message)
    repetitive_sms_checker = WifiUser::UseCase::RepetitiveSmsChecker.new(
      smslog_model: WifiUser::Repository::Smslog.new,
    )

    repetitive_sms_checker.execute(WifiUser::PhoneNumber.internationalise(source), message)
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
