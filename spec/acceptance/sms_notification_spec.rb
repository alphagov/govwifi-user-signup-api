RSpec.describe App do
  describe 'POSTing an SMS to /user-signup/sms-notification' do
    let(:from_phone_number) { '07700900000' }
    let(:notify_token) { ENV['GOVNOTIFY_BEARER_TOKEN'] }
    let(:payload) do
      {
        source_number: from_phone_number,
        destination_number: '',
        message: 'Go'
      }.to_json
    end

    def post_sms_notification
      post "/user-signup/sms-notification/notify", payload, 'HTTP_AUTHORIZATION' => "Bearer #{notify_token}"
    end

    it 'returns no sensitive information to sms provider' do
      allow_any_instance_of(WifiUser::UseCase::SmsResponse).to receive(:execute).and_return 'Sensitive info'
      post_sms_notification
      expect(last_response.body).to eq('')
    end

    describe 'from a phone number' do
      let(:from_phone_number) { '07700900000' }

      it 'calls WifiUser::UseCase::SmsResponse#execute' do
        expect_any_instance_of(WifiUser::UseCase::SmsResponse).to \
          receive(:execute).with(contact: from_phone_number, sms_content: 'Go')
        post_sms_notification
      end
    end

    describe 'from a different phone number' do
      let(:from_phone_number) { '07700900001' }
      it 'calls WifiUser::UseCase::SmsResponse#execute' do
        expect_any_instance_of(WifiUser::UseCase::SmsResponse).to \
          receive(:execute).with(contact: from_phone_number, sms_content: 'Go')
        post_sms_notification
      end
    end

    describe 'environment specific template finder' do
      before do
        allow_any_instance_of(WifiUser::UseCase::SmsResponse).to receive(:execute)
      end

      context 'production' do
        it 'uses the rack environment variable' do
          ENV['RACK_ENV'] = 'production'

          expect(WifiUser::UseCase::SmsTemplateFinder).to receive(:new).with(environment: 'production')
          post_sms_notification
        end
      end

      context 'staging' do
        it 'uses the rack environment variable' do
          ENV['RACK_ENV'] = 'staging'

          expect(WifiUser::UseCase::SmsTemplateFinder).to receive(:new).with(environment: 'staging')
          post_sms_notification
        end
      end
    end
  end
end
