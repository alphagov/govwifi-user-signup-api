class WifiUser::UseCase::SponsorUsers
  def initialize(user_model:, allowlist_checker:, send_sms_gateway:, send_email_gateway:, logger: Logger.new($stdout))
    @logger = logger
    @user_model = user_model
    @allowlist_checker = allowlist_checker
    @send_sms_gateway = send_sms_gateway
    @send_email_gateway = send_email_gateway
    @contact_sanitiser = WifiUser::UseCase::ContactSanitiser.new
  end

  def execute(unsanitised_sponsees, sponsor)
    sponsor_address = Mail::Address.new(sponsor).address

    if allowlist_checker.execute(sponsor_address)[:success]
      sponsees = sanitise_sponsees(unsanitised_sponsees)
      failed_sponsees = invite_sponsees(sponsor, sponsor_address, sponsees)[:failed]
      send_confirmation_email(sponsor_address, sponsees, failed_sponsees:)
    else
      logger.info("Unsuccessful sponsor signup attempt: #{sponsor_address}")
    end
  rescue Mail::Field::ParseError => e
    logger.warn("unable to parse address: #{e}")
  end

private

  attr_reader :user_model, :contact_sanitiser, :allowlist_checker, :send_sms_gateway, :send_email_gateway, :logger

  def sanitise_sponsees(contacts)
    contacts.map { |contact| contact_sanitiser.execute(contact) }.compact.uniq
  end

  def invite_sponsees(sponsor, sponsor_address, sponsees)
    failed_sponsees = sponsees.reject do |sponsee|
      if email?(sponsee)
        sponsee_address = Mail::Address.new(sponsee).address
        sponsor_email(sponsor, sponsor_address, sponsee_address)
      else
        sponsor_phone_number(sponsor_address, sponsee)
      end
    end
    {
      success: (sponsees.to_set - failed_sponsees.to_set).to_a,
      failed: failed_sponsees,
    }
  end

  def sponsor_phone_number(actual_sponsor, sponsee)
    login_details = user_model.generate(contact: sponsee, sponsor: actual_sponsor)
    send_sms_gateway.execute(
      phone_number: sponsee,
      template_id: config["notify_sms_template_ids"]["credentials"],
      template_parameters: {
        login: login_details[:username],
        pass: login_details[:password],
      },
    ).success
  end

  def sponsor_email(sponsor, sponsor_address, sponsee_address)
    login_details = user_model.generate(contact: sponsee_address, sponsor: sponsor_address)
    send_email_gateway.execute(
      email_address: sponsee_address,
      template_id: config["notify_email_template_ids"]["sponsored_credentials"],
      template_parameters: login_details.merge(sponsor:),
      reply_to_id: do_not_reply_email_address_id,
    ).success
  end

  def config
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml")
  end

  def send_confirmation_email(sponsor, sponsees, failed_sponsees: [])
    return send_failed_sponsoring_email(sponsor, failed_sponsees:) if sponsees.empty? || !failed_sponsees.empty?
    return send_confirmation_singular(sponsor, sponsees) if sponsees.length == 1

    send_confirmation_plural(sponsor, sponsees)
  end

  def send_confirmation_plural(sponsor_address, sponsees)
    send_email_gateway.execute(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template["plural"],
      template_parameters: {
        number_of_accounts: sponsees.length,
        contacts: sponsees.join("\r\n"),
      },
      reply_to_id: do_not_reply_email_address_id,
    )
  end

  def send_confirmation_singular(sponsor_address, sponsees)
    send_email_gateway.execute(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template["singular"],
      template_parameters: {
        contact: sponsees.first,
      },
      reply_to_id: do_not_reply_email_address_id,
    )
  end

  def send_failed_sponsoring_email(sponsor_address, failed_sponsees: [])
    send_email_gateway.execute(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template["failed"],
      template_parameters: {
        failedSponsees: format_failed_sponsees(failed_sponsees),
      },
      reply_to_id: do_not_reply_email_address_id,
    )
  end

  def sponsor_confirmation_template
    config["notify_email_template_ids"]["sponsor_confirmation"]
  end

  def email?(sponsee)
    Mail::Address.new(sponsee).address.match?(URI::MailTo::EMAIL_REGEXP)
  rescue Mail::Field::ParseError
    false
  end

  def do_not_reply_email_address_id
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml").fetch("do_not_reply_email_id")
  end

  def format_failed_sponsees(failed_sponsees)
    failed_sponsees.map { |sponsee| "* #{sponsee}" }.join("\n")
  end
end
