RSpec.describe App do
  before { ENV['AUTHORISED_EMAIL_DOMAINS_REGEX'] = '.gov.uk$' }

  describe 'POSTing a SubscriptionConfirmation to /user-signup/email-notification' do
    it 'makes a GET request to the SubscribeURL' do
      stub_request(:any, 'www.example.com')
      post '/user-signup/email-notification', { Type: 'SubscriptionConfirmation', SubscribeURL: 'http://www.example.com' }.to_json

      expect(WebMock).to have_requested(:get, 'www.example.com')
    end
  end

  describe 'POSTing a Notification to /user-signup/email-notification' do
    let(:bucket_name) { 'stub-bucket-name' }
    let(:object_key) { 'stub-object-key' }

    let(:ses_notification) do
      # Notification format taken from
      # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications-examples.html
      {
        mail: {
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

    def post_notification
      post '/user-signup/email-notification', {
        Type: 'Notification',
        Message: ses_notification.to_json
      }.to_json
    end

    describe 'when the Notification is a signup' do
      let(:from_address) { 'adrian@adrian.gov.uk' }
      let(:to_address) { 'signup@wifi.service.gov.uk' }

      before do
        allow_any_instance_of(EmailSignup).to receive(:execute)
      end

      it 'returns a 200' do
        post_notification
        expect(last_response).to be_ok
      end

      it 'calls UserSignup#execute' do
        expect_any_instance_of(EmailSignup).to \
          receive(:execute).with(contact: from_address)
        post_notification
      end

      it 'returns no sensitive information to SNS' do
        post_notification
        expect(last_response.body).to eq('')
      end
    end

    describe 'when the Notification is a sponsor' do
      let(:from_address) { 'chris@example.com' }
      let(:to_address) { 'sponsor@wifi.service.gov.uk' }
      let(:email_fetcher) { double(fetch: '') }
      let(:sponsee_extractor) { double(execute: []) }
      let(:sponsor_users) { double(execute: '') }

      before do
        allow(S3ObjectFetcher).to receive(:new).and_return(email_fetcher)
        allow(EmailSponseesExtractor).to receive(:new).and_return(sponsee_extractor)
        allow(SponsorUsers).to receive(:new).and_return(sponsor_users)
      end

      it 'returns a 200' do
        post_notification
        expect(last_response).to be_ok
      end

      it 'constructs S3ObjectFetcher with the bucket and keyName' do
        post_notification
        expect(S3ObjectFetcher).to have_received(:new)
                                    .with(bucket: bucket_name, key: object_key)
      end

      it 'constructs EmailSponseesExtractor with the S3ObjectFetcher' do
        post_notification
        expect(EmailSponseesExtractor).to have_received(:new).with(email_fetcher: email_fetcher)
      end

      it 'calls SponsorUsers with the sponsees from EmailSponseesExtractor and from address' do
        allow(sponsee_extractor).to receive(:execute) { ['a_fantastic_email@example.com'] }
        post_notification
        expect(sponsor_users).to have_received(:execute)
                                   .with(['a_fantastic_email@example.com'], 'chris@example.com')
      end
    end
  end
end
