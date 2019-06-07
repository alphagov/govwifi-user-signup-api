RSpec.describe App do
  describe 'POSTing a Notification to /user-signup/email-notification' do
    let(:bucket_name) { 'stub-bucket-name' }
    let(:object_key) { 'stub-object-key' }
    let(:message_id) { 'some-message-id' }

    let(:ses_notification) do
      # Notification format taken from
      # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications-examples.html
      {
        mail: {
          messageId: message_id,
          commonHeaders: {
            from: [from_address],
            to: [to_address]
          }
        },
        receipt: {
          action: {
            bucketName: bucket_name,
            objectKey: object_key
          }
        }
      }
    end

    let(:sns_headers) do
      {
        'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'Notification'
      }
    end

    def post_notification
      post '/user-signup/email-notification', {
        Type: 'Notification',
        Message: ses_notification.to_json
      }.to_json, sns_headers
    end

    describe 'when the Notification is a signup' do
      let(:from_address) { 'adrian@adrian.gov.uk' }
      let(:to_address) { 'signup@wifi.service.gov.uk' }

      before do
        allow_any_instance_of(WifiUser::UseCase::EmailSignup).to receive(:execute)
      end

      it 'returns a 200' do
        post_notification
        expect(last_response).to be_ok
      end

      it 'calls UserSignup#execute' do
        expect_any_instance_of(WifiUser::UseCase::EmailSignup).to \
          receive(:execute).with(contact: from_address)
        post_notification
      end

      it 'returns no sensitive information to SNS' do
        post_notification
        expect(last_response.body).to eq('')
      end

      describe 'POSTing a Amazon SES Setup Notification to /user-signup/email-notification' do
        let(:message_id) { 'AMAZON_SES_SETUP_NOTIFICATION' }

        it 'ignores the message' do
          expect { post_notification }.to_not(raise_error)
        end
      end
    end

    describe 'when the Notification is a sponsor' do
      let(:from_address) { 'chris@example.com' }
      let(:to_address) { 'sponsor@wifi.service.gov.uk' }
      let(:email_fetcher) { double(fetch: '') }
      let(:sponsee_extractor) { double(execute: []) }
      let(:sponsor_users) { double(execute: '') }

      before do
        allow(Common::Gateway::S3ObjectFetcher).to receive(:new).and_return(email_fetcher)
        allow(WifiUser::UseCase::EmailSponseesExtractor).to receive(:new).and_return(sponsee_extractor)
        allow(WifiUser::UseCase::SponsorUsers).to receive(:new).and_return(sponsor_users)
      end

      it 'returns a 200' do
        post_notification
        expect(last_response).to be_ok
      end

      it 'constructs Common::Gateway::S3ObjectFetcher with the bucket and keyName' do
        post_notification
        expect(Common::Gateway::S3ObjectFetcher).to have_received(:new)
                                    .with(bucket: bucket_name, key: object_key)
      end

      it 'constructs WifiUser::UseCase::EmailSponseesExtractor with the Common::Gateway::S3ObjectFetcher' do
        post_notification
        expect(WifiUser::UseCase::EmailSponseesExtractor).to have_received(:new)
          .with(email_fetcher: email_fetcher, sponsor_address: from_address)
      end

      it 'calls WifiUser::UseCase::SponsorUsers with the sponsees from WifiUser::UseCase::EmailSponseesExtractor and from address' do
        allow(sponsee_extractor).to receive(:execute) { ['a_fantastic_email@example.com'] }
        post_notification
        expect(sponsor_users).to have_received(:execute)
                                   .with(['a_fantastic_email@example.com'], 'chris@example.com')
      end
    end
  end
end
