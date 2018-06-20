RSpec.describe App do
  describe 'POSTing a SubscriptionConfirmation to /user-signup/email-notification' do
    it 'makes a GET request to the SubscribeURL' do
      stub_request(:any, "www.example.com")
      post '/user-signup/email-notification', { Type: "SubscriptionConfirmation", SubscribeURL: 'http://www.example.com' }.to_json

      expect(WebMock).to have_requested(:get, "www.example.com")
    end
  end

  describe 'POSTing a signup Notification to /user-signup/email-notification' do
    it 'returns a 200' do
      # Notification format taken from
      # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications-examples.html
      notification = {
        commonHeaders: {
          from: [
            'adrian@govwifi.service.gov.uk'
          ],
          to: [
            'signup@govwifi.service.gov.uk'
          ]
        }
      }
      post '/user-signup/email-notification', { Type: "Notification", Message: notification.to_json }.to_json
      expect(last_response).to be_ok
    end
  end
end
