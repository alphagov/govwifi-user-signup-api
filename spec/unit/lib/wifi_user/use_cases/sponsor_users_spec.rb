describe WifiUser::UseCase::SponsorUsers do
  let(:notify_email_url) { 'https://api.notifications.service.gov.uk/v2/notifications/email' }
  let(:notify_sms_url) { 'https://api.notifications.service.gov.uk/v2/notifications/sms' }
  let(:username) { 'dummy_username' }
  let(:password) { 'dummy_password' }
  let(:environment) { 'production' }
  let(:production_do_not_reply_id) { '0d22d71f-afa3-4c72-8cd4-7716678dbd43' }
  let(:staging_do_not_reply_id) { '45d6b6c4-6a36-47df-b34d-256b8c0d1511' }

  let(:user_model) { double(generate: { username: username, password: password }) }
  let(:whitelist_checker) { double(execute: { success: true }) }

  subject do
    described_class.new(
      user_model: user_model,
      whitelist_checker: whitelist_checker
    )
  end

  before do
    ENV['RACK_ENV'] = environment
    ENV['NOTIFY_API_KEY'] = 'dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000'
    stub_request(:post, notify_email_url).to_return(status: 200, body: {}.to_json)
    stub_request(:post, notify_sms_url).to_return(status: 200, body: {}.to_json)
    subject.execute(sponsees, sponsor)
  end

  context 'Sponsoring a single email address' do
    let(:sponsor) { 'Chris <chris@gov.uk>' }
    let(:sponsees) { ['adrian@example.com<mailto: adrian@example.com>'] }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it 'Calls user_model#generate with the sponsees email' do
      expect(user_model).to have_received(:generate) \
        .with(contact: 'adrian@example.com', sponsor: 'chris@gov.uk')
    end

    it 'Sends an email to the sponsee_address with the login details' do
      expect(a_signup_email_request(email: 'adrian@example.com')).to have_been_made.once
    end

    it 'Sends a single user confirmation email to the sponsor' do
      body = {
        email_address: 'chris@gov.uk',
        template_id: '30ab6bc5-20bf-45af-b78d-34cacc0027cd',
        personalisation: {
          contact: 'adrian@example.com'
        },
        email_reply_to_id: do_not_reply_id
      }
      expect(a_request(:post, notify_email_url).with(notify_request(body))).to have_been_made.once
    end
  end

  context 'Sponsoring a single phone number' do
    let(:sponsor) { 'Craig <craig@gov.uk>' }
    let(:sponsees) { ['+447700900003'] }

    it 'Calls user_model#generate with the sponsees phone number' do
      expect(user_model).to have_received(:generate) \
        .with(contact: '+447700900003', sponsor: 'craig@gov.uk')
    end

    it 'Sends an sms to the sponsee_address confirming the signup' do
      expect(a_signup_sms_request(phone_number: '+447700900003')).to have_been_made.once
    end
  end

  context 'Sponsoring the same phone number twice' do
    let(:sponsor) { 'Craig <craig@gov.uk>' }
    let(:sponsees) { ['+447700900003', '+447700900003'] }

    it 'Calls user_model#generate once' do
      expect(user_model).to have_received(:generate) \
        .with(contact: '+447700900003', sponsor: 'craig@gov.uk').once
    end
  end

  context 'Sponsoring an email address and a phone number' do
    let(:sponsor) { 'Chloe <chloe@gov.uk>' }
    let(:sponsees) { ['Steve <steve@example.com>', '07700900004'] }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it 'Calls user_model#generate for the email address' do
      expect(user_model).to have_received(:generate) \
        .with(contact: 'steve@example.com', sponsor: 'chloe@gov.uk')
    end

    it 'Calls the user_model#generate for the phone number' do
      expect(user_model).to have_received(:generate) \
        .with(contact: '+447700900004', sponsor: 'chloe@gov.uk')
    end

    it 'Sends an email to the sponsee_address with the login details' do
      expect(a_signup_email_request(email: 'steve@example.com')).to have_been_made.once
    end

    it 'Sends a sms to the sponsee_address confirming the signup' do
      expect(a_signup_sms_request(phone_number: '+447700900004')).to have_been_made.once
    end

    context 'On production' do
      let(:environment) { 'production' }
      let(:plural_sponsor_confirmation_template_id) { '58e8ef4a-ca6b-40cd-81df-ec9c781fed56' }

      it 'Sends a multiple user confirmation email to the sponsor' do
        expect(a_plural_sponsor_confirmation_request).to have_been_made.once
      end
    end

    context 'On staging' do
      let(:environment) { 'staging' }
      let(:plural_sponsor_confirmation_template_id) { '856a5726-1099-4236-b67c-23b654e9edbf' }
      let(:do_not_reply_id) { staging_do_not_reply_id }

      it 'Sends a multiple user confirmation email to the sponsor' do
        expect(a_plural_sponsor_confirmation_request).to have_been_made.once
      end
    end

    def a_plural_sponsor_confirmation_request
      body = {
        email_address: 'chloe@gov.uk',
        template_id: plural_sponsor_confirmation_template_id,
        personalisation: {
          number_of_accounts: 2,
          contacts: "steve@example.com\r\n+447700900004"
        },
        email_reply_to_id: do_not_reply_id
      }
      a_request(:post, notify_email_url).with(notify_request(body))
    end
  end

  context 'Sponsoring invalid contact details' do
    let(:sponsor) { 'Cassandra <cassandra@gov.uk>' }
    let(:sponsees) { %w(Peter Paul 07invalid700900004) }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it 'Does not call user_model#generate' do
      expect(user_model).not_to have_received(:generate)
    end

    it 'Sends a sponsorship failed email to the sponsor' do
      body = {
        email_address: 'cassandra@gov.uk',
        template_id: 'efc83658-dcb5-4401-af42-e26b1945c1a9',
        personalisation: {},
        email_reply_to_id: do_not_reply_id
      }
      expect(a_request(:post, notify_email_url).with(notify_request(body))).to have_been_made.once
    end
  end

  context 'Sponsoring from a non-gov email address' do
    let(:sponsor) { 'adrian <adrian@fake.uk>' }
    let(:sponsees) { ['adrian@notgov.uk'] }
    let(:do_not_reply_id) { staging_do_not_reply_id }
    let(:whitelist_checker) { double(execute: { success: false }) }

    it 'Does not call user_model#generate' do
      expect(user_model).not_to have_received(:generate)
    end
  end

  def a_signup_sms_request(phone_number:)
    body = {
      phone_number: phone_number,
      template_id: '3a4b1ca8-7b26-4266-8b5f-e05fdbd11879',
      personalisation: {
        login: username,
        pass: password,
      }
    }

    a_request(:post, notify_sms_url).with(notify_request(body))
  end

  def a_signup_email_request(email:)
    body = {
      email_address: email,
      template_id: 'fd536b81-bdd7-4b55-98aa-720173718642',
      personalisation: {
        username: username,
        password: password,
        sponsor: sponsor
      },
      email_reply_to_id: do_not_reply_id
    }
    a_request(:post, notify_email_url).with(notify_request(body))
  end

  def notify_request(body)
    {
      body: body,
      headers: {
        'Accept' => '*/*',
        'Content-Type' => 'application/json',
      }
    }
  end
end
