require "mail"
require "notifications/client"

class WifiUser::UseCase::EmailSignup
  def initialize(user_model:, allowlist_checker:, check_user_is_sponsee:, logger: Logger.new($stdout))
    @user_model = user_model
    @allowlist_checker = allowlist_checker
    @check_user_is_sponsee = check_user_is_sponsee
    @logger = logger
  end

  def execute(contact:)
    email_address = Mail::Address.new(contact).address

    if allowlist_checker.execute(email_address)[:success] || check_user_is_sponsee.execute(email_address)
      send_signup_instructions(email_address)
    else
      logger.info("Unsuccessful email signup attempt: #{email_address}")
      send_rejected_email_address_email(email_address)
    end
  rescue Mail::Field::ParseError => e
    logger.warn("unable to parse |#{contact}|: #{e}")
  end

private

  attr_accessor :user_model, :allowlist_checker, :logger, :check_user_is_sponsee

  def send_signup_instructions(email_address)
    client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))

    client.send_email(
      email_address:,
      template_id: credentials_template_id,
      personalisation: user_model.generate(contact: email_address),
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def send_rejected_email_address_email(email_address)
    client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))

    client.send_email(
      email_address:,
      template_id: rejected_email_address_template_id,
      email_reply_to_id: do_not_reply_email_address_id,
    )
  end

  def credentials_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("self_signup_credentials")
  end

  def rejected_email_address_template_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("notify_email_template_ids").fetch("rejected_email_address")
  end

  def do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("do_not_reply_email_id")
  end
end
