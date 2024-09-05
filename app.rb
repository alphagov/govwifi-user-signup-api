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
    raise "This is broken"
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
      user_model: WifiUser::User,
      template_finder:,
      logger:,
    ).execute(
      contact: source,
      sms_content: message,
    )
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
