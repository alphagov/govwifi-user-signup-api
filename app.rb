require 'sensible_logging'
require 'sinatra/base'
require 'net/http'
require 'logger'
require './lib/loader'

class App < Sinatra::Base
  use Raven::Rack if defined? Raven
  register Sinatra::SensibleLogging

  sensible_logging(
    logger: Logger.new(STDOUT)
  )

  configure do
    set :log_level, Logger::DEBUG
  end

  configure :production, :staging do
    set :dump_errors, false
  end

  configure :production do
    set :log_level, Logger::INFO
  end

  get '/healthcheck' do
    'Healthy'
  end

  # rubocop:disable Metrics/BlockLength
  post '/user-signup/email-notification' do
    whitelist_checker = WifiUser::UseCases::CheckIfWhitelistedEmail.new(
      gateway: Common::Gateway::S3ObjectFetcher.new(
        bucket: ENV.fetch('S3_SIGNUP_WHITELIST_BUCKET'),
        key: ENV.fetch('S3_SIGNUP_WHITELIST_OBJECT_KEY'),
        region: 'eu-west-2'
      )
    )

    email_signup_handler = ::WifiUser::UseCase::EmailSignup.new(
      user_model: WifiUser::Repository::User.new,
      whitelist_checker: whitelist_checker,
      logger: logger
    )

    sponsor_signup_handler = ::WifiUser::UseCase::SponsorUsers.new(
      user_model: WifiUser::Repository::User.new,
      whitelist_checker: whitelist_checker,
      logger: logger
    )

    email_parser = WifiUser::UseCase::ParseEmailRequest.new(
      logger: logger
    )

    WifiUser::UseCase::SnsNotificationHandler.new(
      email_signup_handler: email_signup_handler,
      sponsor_signup_handler: sponsor_signup_handler,
      email_parser: email_parser,
      logger: logger
    ).handle(request)
  end
  # rubocop:enable Metrics/BlockLength

  post '/user-signup/sms-notification' do
    logger.info("Processing SMS on /user-signup/sms-notification from #{params[:source]} with message #{params[:message]}")

    template_finder = WifiUser::UseCase::SmsTemplateFinder.new(environment: ENV.fetch('RACK_ENV'))

    WifiUser::UseCase::SmsResponse.new(
      user_model: WifiUser::Repository::User.new,
      template_finder: template_finder
    ).execute(
      contact: params[:source],
      sms_content: params[:message]
    )
    ''
  end
end
