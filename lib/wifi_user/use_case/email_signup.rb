require "mail"
require "notifications/client"

class WifiUser::UseCase::EmailSignup
  def initialize(user_model:, whitelist_checker:, logger: Logger.new(STDOUT))
    @user_model = user_model
    @whitelist_checker = whitelist_checker
    @logger = logger
  end

  def execute(contact:)
    email_address = Mail::Address.new(contact).address

    if whitelist_checker.execute(email_address)[:success]
      send_signup_instructions(email_address)
    else
      logger.info("Unsuccessful email signup attempt: #{email_address}")
    end
  end

private

  attr_accessor :user_model, :whitelist_checker, :logger

  def send_signup_instructions(email_address)
    client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))

    client.send_email(
      email_address: email_address,
      template_id: credentials_template_id,
      personalisation: user_model.generate(contact: email_address),
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("self_signup_credentials")
  end

  def do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("do_not_reply_email_id")
  end
end
