describe WifiUser::UseCase::EmailSignup do
  let(:user_model) { instance_double(WifiUser::Repository::User) }
  let(:allowlist_checker) { double(execute: { success: true }) }
  let(:sponsee_is_user_checker) { double(execute: false) }

  subject do
    described_class.new(
      user_model:,
      allowlist_checker:,
      sponsee_is_user_checker:,
    )
  end

  describe "Using an authorised email domain" do
    let(:notify_email_url) { "https://api.notifications.service.gov.uk/v2/notifications/email" }
    let(:notify_email_request) do
      {
        email_address: created_contact,
        template_id: notify_template_id,
        personalisation: {
          username:,
          password:,
        },
        email_reply_to_id: do_not_reply_id,
      }
    end

    let(:notify_email_stub) do
      stub_request(:post, notify_email_url)
        .with(body: notify_email_request)
        .to_return(status: 200, body: {}.to_json)
    end

    before do
      ENV["RACK_ENV"] = environment

      notify_email_stub

      allow(user_model).to receive(:generate)
        .with(contact: created_contact)
        .and_return(username:, password:)
    end

    after do
      ENV["RACK_ENV"] = "test"
    end

    context "in the production environment" do
      let(:environment) { "production" }
      let(:notify_template_id) { "f18708c0-e857-4f62-b5f3-8f0c75fc2fdb" }
      let(:do_not_reply_id) { "0d22d71f-afa3-4c72-8cd4-7716678dbd43" }

      context "given an email address without a name part" do
        let(:created_contact) { "adrian@gov.uk" }
        let(:username) { "MockUsername" }
        let(:password) { "MockPassword" }

        it "sends email to Notify with the new credentials" do
          subject.execute(contact: created_contact)
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end
    end

    context "in the staging environment" do
      let(:environment) { "staging" }
      let(:notify_template_id) { "96d1f5ac-2ebe-41a7-878f-9a569e0bb55c" }
      let(:do_not_reply_id) { "45d6b6c4-6a36-47df-b34d-256b8c0d1511" }

      context "given an email address with a name part" do
        let(:created_contact) { "ryan@gov.uk" }
        let(:username) { "MockUsername2" }
        let(:password) { "MockPassword2" }

        it "sends email to Notify with the new credentials" do
          subject.execute(contact: "Ryan <ryan@gov.uk>")
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context "given an email address with a capitalised domain" do
        let(:created_contact) { "name@GOV.uk" }
        let(:username) { "qwert" }
        let(:password) { "qwertpass" }

        it "sends email to Notify with the new credentials" do
          subject.execute(contact: "Name <name@GOV.uk>")
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context "given an email address with a non-gov domain" do
        let(:allowlist_checker) { double(execute: { success: false }) }
        let(:created_contact) { "ryan@example.com" }
        let(:username) { "irrelevant" }
        let(:password) { "irrelephant" }
        let(:notify_template_id) { "dabb9566-ae35-4ada-a9c5-2dd0db099539" }

        let(:notify_email_request) do
          {
            email_address: created_contact,
            template_id: notify_template_id,
            email_reply_to_id: do_not_reply_id,
          }
        end

        before { subject.execute(contact: "Ryan <ryan@example.com>") }

        it "does not create a user" do
          expect(user_model).not_to receive(:generate)
        end

        it "sends an email to Notify" do
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end

      context "given an email address with a non-gov domain, but email is sponsored" do
        let(:allowlist_checker) { double(execute: { success: false }) }
        let(:sponsee_is_user_checker) { double(execute: true) }
        let(:notify_template_id) { "4f6bae31-5add-43a9-b0e3-7db43452676e" }
        let(:sponsored_user) { FactoryBot.create(:user_details, :recent, :active, :sponsored) }
        let(:created_contact) { sponsored_user.contact }
        let(:sponsor) { sponsored_user.sponsor }
        let(:username) { sponsored_user.contact }
        let(:password) { sponsored_user.password }
        let(:notify_email_request) do
          {
            email_address: created_contact,
            template_id: notify_template_id,
            personalisation: {
              username:,
              password:,
              sponsor:,
            },
            email_reply_to_id: do_not_reply_id,
          }
        end

        it "will not create a new User" do
          expect { subject.execute(contact: created_contact) }.to_not change(WifiUser::Repository::User, :count)
        end

        it "sends an email to Notify" do
          subject.execute(contact: created_contact)
          expect(notify_email_stub).to have_been_requested.times(1)
        end
      end
    end
  end

  describe "Using a unparsable contact" do
    it "logs the error" do
      expect(subject.send(:logger)).to receive(:warn)

      subject.execute(contact: "Ryan <ryan@example.com")
    end
  end
end
