describe WifiUser::UseCase::SmsResponse do
  let(:user_model) { WifiUser::User }
  let(:template_finder) { double(execute: notify_template_id) }
  subject { described_class.new(user_model:, template_finder:) }

  context "With named number" do
    let(:phone_number) { "HIDDENNUMBER" }
    let(:notify_template_id) { "00000000-7777-8888-9999-000000000000" }
    let(:notify_sms_url) { stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/sms") }

    it "does not create a user" do
      expect(user_model).to_not receive(:find_or_create)
      subject.execute(contact: phone_number, sms_content: "")
    end

    it "does not send a message to this number" do
      subject.execute(contact: phone_number, sms_content: "")
      expect(notify_sms_url).not_to have_been_requested
    end
  end

  context "With valid phone number" do
    before do
      expect(user_model).to receive(:find_or_create).with(contact: phone_number).and_return(username:, password:)
    end

    let(:username) { "hello" }
    let(:password) { "password" }
    let(:phone_number) { "+447700900003" }
    let(:notify_sms_url) { "https://api.notifications.service.gov.uk/v2/notifications/sms" }
    let(:notify_template_id) { "00000000-7777-8888-9999-000000000000" }
    let(:notify_sms_request) do
      {
        phone_number:,
        template_id: notify_template_id,
        personalisation: {
          login: username,
          pass: password,
        },
      }
    end
    let!(:notify_sms_stub) do
      stub_request(:post, notify_sms_url).with(body: notify_sms_request)\
        .to_return(status: 200, body: {}.to_json)
    end

    it "Creates a user with the phone number with a +44 already" do
      subject.execute(contact: "+447700900003", sms_content: "")
    end

    it "Creates a user prepended by +44" do
      subject.execute(contact: "07700900003", sms_content: "")
    end

    it "Creates a user prepended by +" do
      subject.execute(contact: "447700900003", sms_content: "")
    end

    context "Calls the template finder with the message content" do
      it "with a message of Go" do
        subject.execute(contact: "447700900003", sms_content: "Go")
        expect(template_finder).to have_received(:execute).with(message_content: "Go")
      end

      it "with a message of Help" do
        subject.execute(contact: "447700900003", sms_content: "Help")
        expect(template_finder).to have_received(:execute).with(message_content: "Help")
      end
    end

    it "does not raise an error" do
      expect {
        subject.execute(contact: "447700900003", sms_content: "Help")
      }.to_not raise_error
    end

    context "For one set of credentials" do
      let(:username) { "AnExampleUsername" }
      let(:password) { "AnExamplePassword" }
      let(:phone_number) { "+447700900005" }

      it "Sends details to Notify" do
        subject.execute(contact: phone_number, sms_content: "")
        expect(notify_sms_stub).to have_been_requested.times(1)
      end
    end

    context "With a separate set of credentials" do
      let(:username) { "AnotherUsername" }
      let(:password) { "AnotherPassword" }
      let(:phone_number) { "+447700900006" }
      let(:notify_template_id) { "00000000-3333-3333-3333-000000000000" }

      it "Sends details to Notify" do
        subject.execute(contact: phone_number, sms_content: "")
        expect(notify_sms_stub).to have_been_requested.times(1)
      end
    end
  end

  context "With Notifications::Client::BadRequestError" do
    let(:username) { "hello" }
    let(:password) { "password" }
    let(:phone_number) { "+447700900003" }
    let(:notify_sms_url) { "https://api.notifications.service.gov.uk/v2/notifications/sms" }
    let(:notify_template_id) { "00000000-7777-8888-9999-000000000000" }
    let(:notify_sms_request) do
      {
        phone_number:,
        template_id: notify_template_id,
        personalisation: {
          login: username,
          pass: password,
        },
      }
    end

    context "with ValidationError" do
      let!(:notify_sms_stub) do
        stub_request(:post, notify_sms_url).with(body: notify_sms_request)
          .to_return(status: 400, body: {
            "errors": [
              {
                "error": "ValidationError",
                "message": "foo",
              },
            ],
            "status_code": 400,
          }.to_json)
      end

      before do
        expect(user_model).to receive(:find_or_create).with(contact: phone_number).and_return(username:, password:)
      end

      it "doesn't raise error" do
        expect {
          subject.execute(contact: "447700900003", sms_content: "")
        }.not_to raise_error
      end
    end

    context "with FooError" do
      let!(:notify_sms_stub) do
        stub_request(:post, notify_sms_url).with(body: notify_sms_request)
          .to_return(status: 400, body: {
            "errors": [
              {
                "error": "FooError",
                "message": "foo",
              },
            ],
            "status_code": 400,
          }.to_json)
      end

      before do
        expect(user_model).to receive(:find_or_create).with(contact: phone_number).and_return(username:, password:)
      end

      it "raises original error" do
        expect {
          subject.execute(contact: "447700900003", sms_content: "")
        }.to raise_error(Notifications::Client::BadRequestError)
      end
    end
  end
end
