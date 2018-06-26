require 'sinatra/base'
require 'net/http'
require 'notifications/client'

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
    from_address = ses_notification['commonHeaders']['from'][0]
    signup_user(email: from_address) if authorised_email_domain?(from_address)
  end

  def signup_user(email:)
    login_details = User.new.generate(email: email)
    client = Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))

    client.send_email(
      email_address: email,
      template_id: ENV.fetch('NOTIFY_USER_SIGNUP_EMAIL_TEMPLATE_ID'),
      personalisation: login_details
    )
  end

  def authorised_email_domain?(from_address)
    authorised_email_domains_regex.match?(from_address)
  end

  def authorised_email_domains_regex
    Regexp.new(ENV.fetch('AUTHORISED_EMAIL_DOMAINS_REGEX'))
  end
end
