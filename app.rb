require 'sinatra/base'
require 'net/http'

require './lib/email_signup.rb'
require './lib/user.rb'

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

private

  def handle_signup_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    logger.info("Handling signup request from #{from_address}")
    EmailSignup.new(user_model: User.new).execute(contact: from_address)
  end
end
