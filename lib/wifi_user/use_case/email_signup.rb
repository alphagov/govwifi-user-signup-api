require 'mail'
require 'notifications/client'

class WifiUser::UseCase::EmailSignup
  def initialize(user_model:, user_db_model:)
    @user_model = user_model
    @user_db_model = user_db_model
  end

  def execute(contact:)
    email_address = Mail::Address.new(contact).address

    return unless Common::EmailAddress.authorised_email_domain?(email_address)

    login_details = user_model.generate(contact: email_address)

    user_db_model.generate(contact: email_address)

    send_signup_instructions(email_address, login_details)
  end

private

  attr_accessor :user_model, :user_db_model

  def send_signup_instructions(email_address, login_details)
    client = Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))

    client.send_email(
      email_address: email_address,
      template_id: credentials_template_id,
      personalisation: login_details,
      email_reply_to_id: do_not_reply_email_address_id
    )
  end

  def credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch('notify_email_template_ids').fetch('self_signup_credentials')
  end

  def do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch('do_not_reply_email_id')
  end
end
