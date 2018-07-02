RSpec.describe SmsSignup do
  let(:user_model) { instance_double(User) }
  subject { described_class.new(user_model: user_model) }

  before do
    expect(user_model).to receive(:generate).with(contact: phone_number).and_return(username: username, password: password)
    ENV['NOTIFY_USER_SIGNUP_SMS_TEMPLATE_ID'] = notify_template_id
  end

  let(:username) { 'hello' }
  let(:password) { 'password' }
  let(:phone_number) { '+447700900003' }
  let(:notify_sms_url) { 'https://api.notifications.service.gov.uk/v2/notifications/sms' }
  let(:notify_template_id) { '00000000-7777-8888-9999-000000000000' }
  let(:notify_sms_request) do
    {
      phone_number: phone_number,
      template_id: notify_template_id,
      personalisation: {
        login: username,
        pass: password,
      }
    }
  end
  let!(:notify_sms_stub) do
    stub_request(:post, notify_sms_url).with(body: notify_sms_request)\
      .to_return(status: 200, body: {}.to_json)
  end

  it 'Creates a user with the phone number with a +44 already' do
    subject.execute(contact: '+447700900003')
  end

  it 'Creates a user prepended by +44' do
    subject.execute(contact: '07700900003')
  end

  it 'Creates a user prepended by +' do
    subject.execute(contact: '447700900003')
  end

  context 'For one set of credentials' do
    let(:username) { 'AnExampleUsername' }
    let(:password) { 'AnExamplePassword' }
    let(:phone_number) { '+447700900005' }

    it 'Sends details to Notify' do
      subject.execute(contact: phone_number)
      expect(notify_sms_stub).to have_been_requested.times(1)
    end
  end

  context 'With a separate set of credentials' do
    let(:username) { 'AnotherUsername' }
    let(:password) { 'AnotherPassword' }
    let(:phone_number) { '+447700900006' }
    let(:notify_template_id) { '00000000-3333-3333-3333-000000000000' }

    it 'Sends details to Notify' do
      subject.execute(contact: phone_number)
      expect(notify_sms_stub).to have_been_requested.times(1)
    end
  end
end
