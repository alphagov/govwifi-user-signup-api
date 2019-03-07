require 'securerandom'
require 'notifications/client'

describe WifiUser::Gateway::GovNotifySMS do
  let(:api_key) { "dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000" }
  
  # modify the actual request
  let(:template_id) { SecureRandom.uuid }
  let(:parameters) { {} }
  let(:phone_number) { '' }

  # modify the stub
  let(:api_url) { 'https://api.notifications.service.gov.uk/v2/notifications/sms' }
  let(:return_status) { 200 }
  let(:return_body) { {} }

  before do
    stub_request(:post, api_url).to_return(status: return_status, body: return_body.to_json)
  end

  let(:subject) { described_class.new(api_key, template_id).execute(phone_number) }

  it 'sends an SMS request' do
    subject
    assert_requested :post, api_url,
      times: 1,
      body: {
        phone_number: phone_number,
        template_id: template_id,
        personalisation: parameters
      }
  end

  context 'on Success' do
    it { expect(subject.success).to be true }
  end
end
