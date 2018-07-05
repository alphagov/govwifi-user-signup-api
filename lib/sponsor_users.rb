require_relative 'phone_number'

class SponsorUsers
  def initialize(user_model:)
    @user_model = user_model
  end

  def execute(sponsees, sponsor)
    validate_sponsees(sponsees)

    sponsor_address = Mail::Address.new(sponsor).address

    invite_sponsees(sponsor, sponsor_address)
    send_confirmation_email(sponsor_address)
  end

private

  def invite_sponsees(sponsor, sponsor_address)
    valid_sponsees.each do |sponsee|
      if is_valid_email(sponsee)
        sponsee_address = Mail::Address.new(sponsee).address
        sponsor_email(sponsor, sponsor_address, sponsee_address)
      else
        sponsee_phone_number = PhoneNumber.internationalise_phone_number(sponsee)
        sponsor_phone_number(sponsor_address, sponsee_phone_number)
      end
    end
  end

  attr_reader :user_model, :valid_sponsees

  def validate_sponsees(sponsees)
    @valid_sponsees = sponsees.select do |sponsee|
      is_valid_email(sponsee) || is_valid_phone_number(sponsee)
    end
    @valid_sponsees.uniq!
  end

  def notify_client
    @client ||= Notifications::Client.new(ENV.fetch('NOTIFY_API_KEY'))
  end

  def sponsor_phone_number(actual_sponsor, sponsee)
    login_details = user_model.generate(contact: sponsee, sponsor: actual_sponsor)
    notify_client.send_sms(
      phone_number: sponsee,
      template_id: config['notify_sms_template_ids']['credentials'],
      personalisation: {
        login: login_details[:username],
        pass: login_details[:password]
      }
    )
  end

  def sponsor_email(sponsor, sponsor_address, sponsee_address)
    login_details = user_model.generate(contact: sponsee_address, sponsor: sponsor_address)
    notify_client.send_email(
      email_address: sponsee_address,
      template_id: config['notify_email_template_ids']['sponsored_credentials'],
      personalisation: login_details.merge(sponsor: sponsor)
    )
  end

  def config
    YAML.load_file("config/#{ENV['RACK_ENV']}.yml")
  end

  def send_confirmation_email(sponsor)
    return send_sponsor_failed(sponsor) if valid_sponsees.empty?
    return send_confirmation_singular(sponsor) if valid_sponsees.length == 1
    send_confirmation_plural(sponsor)
  end

  def send_confirmation_plural(sponsor_address)
    notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template['plural'],
      personalisation: {
        number_of_accounts: valid_sponsees.length,
        contacts: valid_sponsees.join("\r\n")
      }
    )
  end

  def send_confirmation_singular(sponsor_address)
    notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template['singular'],
      personalisation: {
        contact: valid_sponsees.first
      }
    )
  end

  def send_sponsor_failed(sponsor_address)
    notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template['failed'],
      personalisation: {}
    )
  end

  def sponsor_confirmation_template
    config['notify_email_template_ids']['sponsor_confirmation']
  end

  def is_valid_email(sponsee)
    begin
      Mail::Address.new(sponsee).address.match?(URI::MailTo::EMAIL_REGEXP)
    rescue Mail::Field::ParseError
      false
    end
  end

  def is_valid_phone_number(sponsee)
    sponsee.match?(/\A\+?\d{1,15}\Z/)
  end
end