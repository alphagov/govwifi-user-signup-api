require "securerandom"
require "notifications/client"

describe WifiUser::Gateway::GovNotifyEmail do
  let(:api_key) { "dummy_key-00000000-0000-0000-0000-000000000000-00000000-0000-0000-0000-000000000000" }

  # modify the actual request
  let(:template_id) { SecureRandom.uuid }
  let(:parameters) { {} }
  let(:email_address) { "" }
  let(:reply_to_id) { SecureRandom.uuid }

  # modify the stub
  let(:api_url) { "https://api.notifications.service.gov.uk/v2/notifications/email" }
  let(:return_status) { 200 }
  let(:return_body) { {} }

  before do
    stub_request(:post, api_url).to_return(status: return_status, body: return_body.to_json)
  end

  let(:subject) do
    described_class.new.execute(
      email_address:,
      template_id:,
      template_parameters: parameters,
      reply_to_id:,
    )
  end

  it "sends an email request" do
    subject
    assert_requested(
      :post,
      api_url,
      times: 1,
      body: {
        email_address:,
        template_id:,
        personalisation: parameters,
        email_reply_to_id: reply_to_id,
      },
    )
  end

  context "on Success" do
    it { expect(subject.success).to be true }
  end

  # These contexts are to test the different specified errors from the API
  # https://docs.notifications.service.gov.uk/ruby.html#error-codes

  context "with a bad request" do
    let(:return_status) { 400 }

    context "due to server incorrectly set up" do
      let(:return_body) do
        { errors: [
          {
            error: "BadRequestError",
            message: "...",
          },
        ] }
      end

      it { expect { subject }.to raise_error(Notifications::Client::BadRequestError) }
    end

    context "due to bad input" do
      let(:return_body) do
        { errors: [
          {
            error: "ValidationError",
            message: "...",
          },
        ] }
      end

      it { expect(subject.success).to be false }
    end
  end
end
