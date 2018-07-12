require 'sinatra/base'
require 'net/http'

require './lib/sns_notification_handler.rb'
require './lib/email_signup.rb'
require './lib/contact_sanitiser.rb'
require './lib/gateway/s3_object_fetcher.rb'
require './lib/sms_response.rb'
require './lib/sponsor_users.rb'
require './lib/user.rb'
require './lib/sms_template_finder.rb'
require './lib/email_sponsees_extractor.rb'

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
