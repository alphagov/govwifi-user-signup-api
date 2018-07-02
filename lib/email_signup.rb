require 'mail'
require 'notifications/client'

class EmailSignup
  def initialize(user_model:)
    @user_model = user_model
  end

  def execute(contact:)
    email_address = Mail::Address.new(contact).address

    return unless authorised_email_domain?(email_address)

    login_details = user_model.generate(contact: email_address)
    send_signup_instructions(email_address, login_details)
  end

private

  attr_accessor :user_model

  def send_signup_instructions(email_address, login_details)
    client = Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))

    client.send_email(
      email_address: email_address,
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
