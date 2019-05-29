describe App do
  describe 'Signing up to GovWifi via the text message service' do
    let(:from_phone_number) { '07700900000' }
    let(:to_phone_number) { '' }
    let(:message) { 'Go' }
    let(:internationalised_phone_number) { '+447700900000' }
    let(:notify_sms_url) { 'https://api.notifications.service.gov.uk/v2/notifications/sms' }
    let(:notify_template_id) { '24d47eb3-8b02-4eba-aa04-81ffaf4bb1b4' }
    let(:notify_token) { ENV['GOVNOTIFY_BEARER_TOKEN'] }
    let(:created_user) { WifiUser::Repository::User.find(contact: internationalised_phone_number) }

    let(:payload) do
      {
        source_number: from_phone_number,
        destination_number: to_phone_number,
        message: message
      }.to_json
    end

    before do
      ENV['RACK_ENV'] = 'staging'
      stub_request(:post, notify_sms_url).to_return(status: 200, body: {}.to_json)
    end

    it 'sends an SMS containing login details back to the user' do
      post '/user-signup/sms-notification/notify',
        payload,
        'HTTP_AUTHORIZATION' => "Bearer #{notify_token}"

      expected_request = {
        body: {
          "phone_number": internationalised_phone_number,
          "template_id": notify_template_id,
          "personalisation": {
            "login": "#{created_user.username} ",
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

    context 'with a a phone texting itself' do
      shared_examples "rejecting an SMS" do
        let(:sms_response_stub) { class_double(WifiUser::UseCase::SmsResponse).as_stubbed_const }
        let(:subject) do
          post '/user-signup/sms-notification/notify',
            payload,
            'HTTP_AUTHORIZATION' => "Bearer #{notify_token}"
        end

        it 'gives an empty ok' do
          subject
          expect(last_response.ok?).to be true
          expect(last_response.body).to eq('')
        end

        it 'does not send an SMS' do
          expect(sms_response_stub).not_to receive(:new)
          subject
        end
      end

      context 'with both the same number' do
        NUMBERS = %w(07900000001 447900000001 +447900000001).freeze
        NUMBERS.each do |from_number|
          NUMBERS.each do |to_number|
            context "with #{from_number} to #{to_number}" do
              let(:from_phone_number) { from_number }
              let(:to_phone_number) { to_number }

              it_behaves_like "rejecting an SMS"
            end
          end
        end
      end
    end

    context 'with an invalid bearer token' do
      let(:notify_token) { 'INVALID TOKEN' }

      before do
        post '/user-signup/sms-notification/notify',
          { source_number: from_phone_number, message: 'Go', destination_number: '' },
          'HTTP_AUTHORIZATION' => "Bearer #{notify_token}"
      end

      it 'receives an unauthorised response' do
        expect(last_response.status).to eq(401)
      end

      it 'does not send an SMS' do
        expect(a_request(:post, notify_sms_url)).to_not have_been_made
      end
    end
  end
end
