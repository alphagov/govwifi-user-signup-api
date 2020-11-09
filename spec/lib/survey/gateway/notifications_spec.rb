describe Survey::Gateway::Notifications, :focus do
  let!(:user) { FactoryBot.create(:user_details) }

  let(:notify_email_url) { "https://api.notifications.service.gov.uk/v2/notifications/email" }
  let(:notify_email_request) do
    {
      email_address: user.contact,
    }
  end

  let(:notify_email_stub) do
    stub_request(:post, notify_email_url)
      .with(body: notify_email_request)
      .to_return(status: 200, body: {}.to_json)
  end

  before do
    notify_email_stub
  end

  context "when the user signed up via email" do
    let(:gateway) { Survey::Gateway::Notifications.new(user) }

    it "sends an email to them" do
      gateway.execute

      expect(notify_email_stub).to have_been_requested.times(1)
    end
  end
end
