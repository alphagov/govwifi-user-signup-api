require 'sinatra/base'
require 'net/http'

require './lib/email_signup.rb'
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
    payload = JSON.parse request.body.read

    Net::HTTP.get(URI(payload['SubscribeURL'])) if payload['Type'] == 'SubscriptionConfirmation'
    handle_signup_request(JSON.parse(payload['Message'])) if payload['Type'] == 'Notification'
    ''
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

private

  def handle_signup_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    logger.info("Handling signup request from #{from_address}")
    EmailSignup.new(user_model: User.new).execute(contact: from_address)
  end
end
