describe App do
  describe 'Signing up to GovWifi via the text message service' do
    let(:from_phone_number) { '07700900000' }
    let(:internationalised_phone_number) { '+447700900000' }
    let(:notify_sms_url) { 'https://api.notifications.service.gov.uk/v2/notifications/sms' }
    let(:notify_template_id) { '00000000-7777-8888-9999-000000000000' }

    before do
      ENV['NOTIFY_API_KEY'] = 'dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000'
      ENV['NOTIFY_USER_SIGNUP_SMS_TEMPLATE_ID'] = notify_template_id
      stub_request(:post, notify_sms_url).to_return(status: 200, body: {}.to_json)
    end

    it 'sends an SMS containing login details back to the user' do
      post '/user-signup/sms-notification', source: from_phone_number, message: 'Go'

      expected_request = {
        body: {
          "phone_number": internationalised_phone_number,
          "template_id": notify_template_id,
          "personalisation": {
            "login": created_user.username,
            "pass": created_user.password
          }
        },
        headers: {
          'Accept' => '*/*',
          'Content-Type' => 'application/json',
        }
      }

      expect(a_request(:post, notify_sms_url).with(expected_request)).to have_been_made.once
    end

    def created_user
      User.find(contact: internationalised_phone_number)
    end
  end
end
