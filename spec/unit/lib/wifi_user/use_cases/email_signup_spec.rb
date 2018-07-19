describe WifiUser::UseCase::EmailSignup do
  let(:user_model) { instance_double(WifiUser::Repository::User) }
  subject { described_class.new(user_model: user_model) }

  describe 'Using an authorised email domain' do
    let(:notify_email_url) { 'https://api.notifications.service.gov.uk/v2/notifications/email' }
    let(:notify_email_request) do
      {
        email_address: created_contact,
        template_id: notify_template_id,
        personalisation: {
          username: username,
          password: password,
        }
      }
    end
    let!(:notify_email_stub) do
      stub_request(:post, notify_email_url).with(body: notify_email_request)\
      .to_return(status: 200, body: {}.to_json)
    end
    let(:notify_api_key) { 'dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000' }

    before do
      ENV['NOTIFY_API_KEY'] = notify_api_key
      ENV['RACK_ENV'] = environment

      expect(user_model).to receive(:generate) \
        .with(contact: created_contact) \
        .and_return(username: username, password: password)
    end

    context 'given an email address without a name part' do
      let(:created_contact) { 'adrian@gov.uk' }
      let(:environment) { 'production' }
      let(:notify_template_id) { 'f18708c0-e857-4f62-b5f3-8f0c75fc2fdb' }
      let(:username) { 'MockUsername' }
      let(:password) { 'MockPassword' }

      it 'sends email to Notify with the new credentials' do
        subject.execute(contact: created_contact)
        expect(notify_email_stub).to have_been_requested.times(1)
      end
    end

    context 'given an email address with a name part' do
      let(:created_contact) { 'ryan@gov.uk' }
      let(:environment) { 'staging' }
      let(:notify_template_id) { '96d1f5ac-2ebe-41a7-878f-9a569e0bb55c' }
      let(:username) { 'MockUsername2' }
      let(:password) { 'MockPassword2' }

      it 'sends email to Notify with the new credentials' do
        subject.execute(contact: 'Ryan <ryan@gov.uk>')
        expect(notify_email_stub).to have_been_requested.times(1)
      end
    end
  end

  describe 'Using an unauthorised email domain' do
    it 'does not call the User#generate' do
      expect(user_model).not_to receive(:generate)
      subject.execute(contact: 'Ryan <ryan@example.com>')
    end
  end
end
