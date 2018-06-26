RSpec.describe App do
  before { ENV['AUTHORISED_EMAIL_DOMAINS_REGEX'] = '.gov.uk$' }

  describe 'POSTing a SubscriptionConfirmation to /user-signup/email-notification' do
    it 'makes a GET request to the SubscribeURL' do
      stub_request(:any, 'www.example.com')
      post '/user-signup/email-notification', { Type: 'SubscriptionConfirmation', SubscribeURL: 'http://www.example.com' }.to_json

      expect(WebMock).to have_requested(:get, 'www.example.com')
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
        Type: 'Notification',
        Message: ses_notification.to_json
      }.to_json
    end

    it 'returns a 200' do
      post_notification
      expect(last_response).to be_ok
    end

    describe 'from an authorised email address' do
      let(:notify_email_url) { 'https://api.notifications.service.gov.uk/v2/notifications/email' }
      let(:notify_api_key) { 'mock_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000' }
      let(:notify_template_id) { '00000000-0000-4321-1234-000000000000' }
      let!(:notify_stub) { stub_request(:post, notify_email_url).to_return(status: 200, body: {}.to_json) }
      let(:from_address) { 'adrian@adrian.gov.uk' }
      let(:username) { 'MockUsername' }
      let(:password) { 'MockPassword' }

      before do
        ENV['NOTIFY_API_KEY'] = notify_api_key
        ENV['NOTIFY_USER_SIGNUP_EMAIL_TEMPLATE_ID'] = notify_template_id

        expect_any_instance_of(User).to \
          receive(:generate).with(email: from_address) \
          .and_return(username: username, password: password)
      end

      it 'sends email to Notify with the new credentials' do
        post_notification
        notify_body = {
          email_address: from_address,
          template_id: notify_template_id,
          personalisation: {
            username: username,
            password: password
          }
        }
        expect(notify_stub.with(body: notify_body)).to have_been_requested.times(1)
      end

      it 'returns no sensitive information to SNS' do
        post_notification
        expect(last_response.body).to eq('')
      end
    end

    describe 'from an unauthorised email address' do
      let(:from_address) { 'adrian@madetech.com' }

      it 'does not call User#generate' do
        expect_any_instance_of(User).to_not receive(:generate)
        post_notification
      end
    end
  end
end
