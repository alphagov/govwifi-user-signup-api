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
    let(:notify_email_stub) do
      stub_request(:post, notify_email_url)
        .with(body: notify_email_request)
        .to_return(status: 200, body: {}.to_json)
    end

    let(:notify_api_key) { 'dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000' }

    before do
      ENV['NOTIFY_API_KEY'] = notify_api_key
      ENV['RACK_ENV'] = environment

      notify_email_stub

      # allow(notify_email_stub).to receive(:execute)
      # .with(body: notify_email_request)
      # .and_return(body: notify_email_request)

      allow(user_model).to receive(:generate)
        .with(contact: created_contact)
        .and_return(username: username, password: password)
    end

    context 'in the production environment' do
      let(:environment) { 'production' }
      let(:notify_template_id) { 'f18708c0-e857-4f62-b5f3-8f0c75fc2fdb' }
      let(:created_contact) { 'adrian@gov.uk' }
      let(:username) { 'MockUsername' }
      let(:password) { 'MockPassword' }
      # let(:template_finder) { double(execute: notify_template_id) }

      context 'given an email address without a name part' do

        it 'sends email to Notify with the new credentials' do
          subject.execute(contact: created_contact)
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context 'bounces reply emails' do
        it 'with content' do
          subject.execute(contact: created_contact)
          expect(notify_email_stub).to receive(:execute).and_return(body: "")
        end
      end
    end

    context 'in the staging environment' do
      let(:environment) { 'staging' }
      let(:notify_template_id) { '96d1f5ac-2ebe-41a7-878f-9a569e0bb55c' }

      context 'given an email address with a name part' do
        let(:created_contact) { 'ryan@gov.uk' }
        let(:username) { 'MockUsername2' }
        let(:password) { 'MockPassword2' }

        it 'sends email to Notify with the new credentials' do
          subject.execute(contact: 'Ryan <ryan@gov.uk>')
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context 'given an email address with a capitalised domain' do
        let(:created_contact) { 'name@GOV.uk' }
        let(:username) { 'qwert' }
        let(:password) { 'qwertpass' }

        it 'sends email to Notify with the new credentials' do
          subject.execute(contact: 'Name <name@GOV.uk>')
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context 'given an email address with a non-gov domain' do
        let(:created_contact) { 'irrelevant@somewhere.uk' }
        let(:username) { 'irrelevant' }
        let(:password) { 'irrelephant' }

        before { subject.execute(contact: 'Ryan <ryan@example.com>') }

        it 'does not create a user' do
          expect(user_model).not_to receive(:generate)
        end

        it 'does not send an email to Notify' do
          expect(notify_email_stub).to_not have_been_requested
        end
      end
    end
  end
end
