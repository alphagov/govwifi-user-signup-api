RSpec.describe App do
  before { ENV['AUTHORISED_EMAIL_DOMAINS_REGEX'] = "\.gov\.uk$" }

  describe 'POSTing a SubscriptionConfirmation to /user-signup/email-notification' do
    it 'makes a GET request to the SubscribeURL' do
      stub_request(:any, "www.example.com")
      post '/user-signup/email-notification', { Type: "SubscriptionConfirmation", SubscribeURL: 'http://www.example.com' }.to_json

      expect(WebMock).to have_requested(:get, "www.example.com")
    end
  end

  describe 'POSTing a signup Notification to /user-signup/email-notification' do
    let(:from_address) { 'dummy@example.com' }

    let(:ses_notification) do
      # Notification format taken from
      # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications-examples.html
      {
        commonHeaders: {
          from: [
            from_address
          ],
          to: [
            'signup@govwifi.service.gov.uk'
          ]
        }
      }
    end

    def post_notification
      post '/user-signup/email-notification', {
        Type: "Notification",
        Message: ses_notification.to_json
      }.to_json
    end

    it 'returns a 200' do
      post_notification
      expect(last_response).to be_ok
    end

    describe 'from an authorised email address' do
      let(:from_address) { 'adrian@adrian.gov.uk' }

      it 'calls CreateUser' do
        expect_any_instance_of(User).to receive(:generate).with(email: from_address)
        post_notification
      end

      it 'returns no sensitive information to SNS' do
        post_notification
        expect(last_response.body).to eq('')
      end
    end

    describe 'from an unauthorised email address' do
      let(:from_address) { 'adrian@madetech.com' }

      it 'doesn\'t call CreateUser' do
        expect_any_instance_of(User).to_not receive(:generate)
        post_notification
      end
    end
  end
end
