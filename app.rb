require 'sinatra/base'
require 'net/http'

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
    signup_user(JSON.parse(payload['Message'])) if payload['Type'] == 'Notification'
    ""
  end

private

  def signup_user(ses_notification)
    from_address = ses_notification['commonHeaders']['from'][0]
    User.new.generate(email: from_address) if authorised_email_domains_regex.match? from_address
  end

  def authorised_email_domains_regex
    Regexp.new(ENV.fetch('AUTHORISED_EMAIL_DOMAINS_REGEX'))
  end
end
