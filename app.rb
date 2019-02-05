require 'sensible_logging'
require 'sinatra/base'
require 'net/http'
require 'logger'
require './lib/loader'

class App < Sinatra::Base
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

  post '/user-signup/email-notification' do
    WifiUser::UseCase::SnsNotificationHandler.new(logger).handle(request)
  end

  post '/user-signup/sms-notification' do
    logger.info("Processing SMS on /user-signup/sms-notification from #{params[:source]} with message #{params[:message]}")

    template_finder = WifiUser::UseCase::SmsTemplateFinder.new(environment: ENV.fetch('RACK_ENV'))

    WifiUser::UseCase::SmsResponse.new(
      user_model: WifiUser::Repository::User.new,
      template_finder: template_finder,
      user_db_model: WifiUser::Repository::UserUser.new
    ).execute(
      contact: params[:source],
      sms_content: params[:message]
    )
    ''
  end
end
