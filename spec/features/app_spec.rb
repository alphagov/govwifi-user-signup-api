RSpec.describe App do
  describe 'POST /user-signup/sms-notification' do
    before do
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/sms').
        with(headers: { 'Content-Type' => 'application/json' })
        .to_return(status: 200, body: '{"foo":"bar"}')
    end

    it 'returns 200' do
      post '/user-signup/sms-notification', source: '000000000', message: 'Go', destination: ''
      expect(last_response.body).to eq('')
      expect(last_response).to be_successful
    end
  end

  describe 'POST /user-signup/email-notification' do
    it 'returns 200' do
      post '/user-signup/email-notification', '{"Type":"NOOP"}'
      expect(last_response.body).to eq('')
      expect(last_response).to be_successful
    end
  end
end
