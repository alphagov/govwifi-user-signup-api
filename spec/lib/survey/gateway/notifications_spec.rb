describe Survey::Gateway::Notifications do
  let(:user) { FactoryBot.create(:user_details) }
  let(:mobile_user) { FactoryBot.create(:user_details, :sms) }

  let(:notify_email_url) { "https://api.notifications.service.gov.uk/v2/notifications/email" }
  let(:notify_mobile_url) { "https://api.notifications.service.gov.uk/v2/notifications/sms" }

  let(:notify_email_request) do
    {
      email_address: user.contact,
    }
  end

  let(:notify_mobile_request) do
    {
      phone_number: mobile_user.contact,
    }
  end

  let(:notify_mobile_stub) do
    stub_request(:post, notify_mobile_url)
      .with(body: notify_mobile_request)
      .to_return(status: 200, body: {}.to_json)
  end

  context "when the user signed up via email" do
    let(:notify_email_stub) do
      stub_request(:post, notify_email_url)
        .with(body: notify_email_request)
        .to_return(status: 200, body: {}.to_json)
    end

    before do
      notify_email_stub
    end

    it "sends an email to them" do
      subject.execute(user)

      expect(notify_email_stub).to have_been_requested.times(1)
    end
  end

  context "when the user signed up via mobile" do
    before do
      notify_mobile_stub
    end

    it "sends a text to them" do
      subject.execute(mobile_user)

      expect(notify_mobile_stub).to have_been_requested.once
    end
  end
end
