require 'sinatra/base'
require 'net/http'
require 'require_all'

module Common; end

require_all 'lib'

class App < Sinatra::Base
  configure :production, :staging, :development do
    enable :logging
  end

  get '/healthcheck' do
    'Healthy'
  end

  post '/user-signup/email-notification' do
    SnsNotificationHandler.new(logger).handle(request)
  end

  post '/user-signup/sms-notification' do
    logger.info("Processing SMS on /user-signup/sms-notification from #{params[:source]} with message #{params[:message]}")

    template_finder = SmsTemplateFinder.new(environment: ENV.fetch('RACK_ENV'))

    SmsResponse.new(
      user_model: User.new,
      template_finder: template_finder
    ).execute(
      contact: params[:source],
      sms_content: params[:message]
    )
    ''
  end
end
