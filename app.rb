require 'sinatra/base'
require 'net/http'

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
    payload = JSON.parse request.body.read

    Net::HTTP.get(URI(payload['SubscribeURL'])) if payload['Type'] == 'SubscriptionConfirmation'
    handle_email_notification(payload) if payload['Type'] == 'Notification'
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

  def handle_email_notification(payload)
    ses_notification = JSON.parse(payload['Message'])
    return if ses_notification['mail']['messageId'] == 'AMAZON_SES_SETUP_NOTIFICATION'

    if sponsor_request?(ses_notification)
      handle_sponsor_request(ses_notification)
    else
      handle_signup_request(ses_notification)
    end
  end

  def sponsor_request?(ses_notification)
    recipient_name(ses_notification) == "sponsor"
  end

  def recipient_name(ses_notification)
    Mail::Address.new(ses_notification['mail']['commonHeaders']['to'][0]).local
  end

  def handle_signup_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    logger.info("Handling signup request from #{from_address}")
    EmailSignup.new(user_model: User.new).execute(contact: from_address)
  end

  def handle_sponsor_request(ses_notification)
    from_address = ses_notification['mail']['commonHeaders']['from'][0]
    action = ses_notification['receipt']['action']
    logger.info("Handling sponsor request from #{from_address} with email #{action['objectKey']}")
    email_fetcher = S3ObjectFetcher.new(bucket: action['bucketName'], key: action['objectKey'])
    sponsee_extractor = EmailSponseesExtractor.new(email_fetcher: email_fetcher)
    SponsorUsers.new(user_model: User.new).execute(sponsee_extractor.execute, from_address)
  end
end
