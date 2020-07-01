require "sensible_logging"
require "sinatra/base"
require "net/http"
require "logger"
require "./lib/loader"

class App < Sinatra::Base
  use Raven::Rack if defined? Raven
  register Sinatra::SensibleLogging

  sensible_logging(
    logger: Logger.new(STDOUT),
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
    whitelist_checker = WifiUser::UseCases::CheckIfWhitelistedEmail.new(
      gateway: Common::Gateway::S3ObjectFetcher.new(
        bucket: ENV.fetch("S3_SIGNUP_WHITELIST_BUCKET"),
        key: ENV.fetch("S3_SIGNUP_WHITELIST_OBJECT_KEY"),
        region: "eu-west-2",
      ),
    )

    email_signup_handler = ::WifiUser::UseCase::EmailSignup.new(
      user_model: WifiUser::Repository::User.new,
      whitelist_checker: whitelist_checker,
      logger: logger,
    )

    sponsor_signup_handler = ::WifiUser::UseCase::SponsorUsers.new(
      user_model: WifiUser::Repository::User.new,
      whitelist_checker: whitelist_checker,
      send_sms_gateway: WifiUser::Gateway::GovNotifySMS.new(ENV.fetch("NOTIFY_API_KEY")),
      send_email_gateway: WifiUser::Gateway::GovNotifyEmail.new(ENV.fetch("NOTIFY_API_KEY")),
      logger: logger,
    )

    email_parser = WifiUser::UseCase::ParseEmailRequest.new(
      logger: logger,
    )

    WifiUser::UseCase::SnsNotificationHandler.new(
      email_signup_handler: email_signup_handler,
      sponsor_signup_handler: sponsor_signup_handler,
      email_parser: email_parser,
      logger: logger,
    ).handle(request)
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

    template_finder = WifiUser::UseCase::SmsTemplateFinder.new(environment: ENV.fetch("RACK_ENV"))

    WifiUser::UseCase::SmsResponse.new(
      user_model: WifiUser::Repository::User.new,
      template_finder: template_finder,
      logger: logger,
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

  def is_govnotify_token_valid?
    env.fetch("HTTP_AUTHORIZATION") == "Bearer #{options.govnotify_token}"
  end
end
