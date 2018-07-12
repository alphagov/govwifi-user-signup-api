require_relative 'email_address'

class SponsorUsers
  def initialize(user_model:)
    @user_model = user_model
    @contact_sanitiser = ContactSanitiser.new
  end

  def execute(unsanitised_sponsees, sponsor)
    sponsor_address = Mail::Address.new(sponsor).address

    return unless EmailAddress.authorised_email_domain?(sponsor_address)

    sponsees = sanitise_sponsees(unsanitised_sponsees)
    invite_sponsees(sponsor, sponsor_address, sponsees)
    send_confirmation_email(sponsor_address, sponsees)
  end

private

  attr_reader :user_model, :contact_sanitiser

  def sanitise_sponsees(contacts)
    contacts.map { |contact| contact_sanitiser.execute(contact) }.compact.uniq
  end

  def invite_sponsees(sponsor, sponsor_address, sponsees)
    sponsees.each do |sponsee|
      if email?(sponsee)
        sponsee_address = Mail::Address.new(sponsee).address
        sponsor_email(sponsor, sponsor_address, sponsee_address)
      else
        sponsor_phone_number(sponsor_address, sponsee)
      end
    end
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

  def send_confirmation_email(sponsor, sponsees)
    return send_sponsor_failed(sponsor) if sponsees.empty?
    return send_confirmation_singular(sponsor, sponsees) if sponsees.length == 1
    send_confirmation_plural(sponsor, sponsees)
  end

  def send_confirmation_plural(sponsor_address, sponsees)
    notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template['plural'],
      personalisation: {
        number_of_accounts: sponsees.length,
        contacts: sponsees.join("\r\n")
      }
    )
  end

  def send_confirmation_singular(sponsor_address, sponsees)
    notify_client.send_email(
      email_address: sponsor_address,
      template_id: sponsor_confirmation_template['singular'],
      personalisation: {
        contact: sponsees.first
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

  def email?(sponsee)
    begin
      Mail::Address.new(sponsee).address.match?(URI::MailTo::EMAIL_REGEXP)
    rescue Mail::Field::ParseError
      false
    end
  end
end
