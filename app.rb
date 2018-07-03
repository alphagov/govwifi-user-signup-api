require 'sinatra/base'
require 'net/http'

require './lib/email_signup.rb'
require './lib/sms_signup.rb'
require './lib/user.rb'
require './lib/sms_template_finder.rb'

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
    SmsSignup.new(user_model: User.new).execute(contact: params[:source])
    ''
  end

private

  def handle_signup_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    logger.info("Handling signup request from #{from_address}")
    EmailSignup.new(user_model: User.new).execute(contact: from_address)
  end
end
