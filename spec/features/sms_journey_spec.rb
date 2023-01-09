require_relative "./shared"

RSpec.describe App do
  include_context "fake notify"
  include_context "simple allow list"

  let(:notify_token) { ENV["GOVNOTIFY_BEARER_TOKEN"] }
  let(:email_request_headers) do
    { "HTTP_X_AMZ_SNS_MESSAGE_TYPE" => "Notification",
      "HTTP_AUTHORIZATION" => "Bearer #{notify_token}" }
  end
  let(:request_body) do
    {
      source_number: from_phone_number,
      destination_number: to_phone_number,
      message:,
    }
  end
  let(:from_phone_number) { "+447701001111" }
  let(:to_phone_number) { "+447701002222" }
  let(:message) { "GO" }

  def do_user_signup
    post "/user-signup/sms-notification/notify", request_body.to_json, email_request_headers
  end

  describe "A valid user signs up" do
    it "creates a new user" do
      expect {
        do_user_signup
      }.to change(WifiUser::User, :count).by(1)
    end
    it "creates a new user with the correct parameters" do
      do_user_signup
      expect(WifiUser::User.find(contact: from_phone_number, sponsor: from_phone_number)).to_not be(nil)
    end
    describe "internationalise phone number" do
      let(:from_phone_number) { "07701001111" }
      it "creates a new user, internationalising the phone number" do
        do_user_signup
        expect(WifiUser::User.find(contact: "+447701001111", sponsor: "+447701001111")).to_not be(nil)
      end
    end
    it "sends an SMS to the user containing credentials" do
      do_user_signup
      user = WifiUser::User.find(contact: "+447701001111")
      expect(Services.notify_client).to have_received(:send_sms).with(
        phone_number: from_phone_number,
        template_id: "sms_credentials_template_id",
        personalisation: {
          login: user.username,
          pass: user.password,
        },
      )
    end
    it "returns 200" do
      do_user_signup
      expect(last_response.body).to eq("")
      expect(last_response).to be_successful
    end
    describe "Sending a help Message" do
      let(:message) { "help" }
      include_examples "sends_template", "sms_help_menu_template_id"
    end
    describe "Sending a recap" do
      let(:message) { "something random" }
      include_examples "sends_template", "sms_recap_template_id"
    end
    describe "Sending a message detailing how to connect using an Android device" do
      let(:message) { "Android" }
      include_examples "sends_template", "sms_device_help_android_template_id"
    end
    describe "Sending a message detailing how to connect using a Blackberry" do
      let(:message) { "Blackberry" }
      include_examples "sends_template", "sms_device_help_blackberry_template_id"
    end
    describe "Sending a message detailing how to connect using a Mac" do
      let(:message) { "Mac" }
      include_examples "sends_template", "sms_device_help_mac_template_id"
    end
    describe "Sending a message detailing how to connect using an iPhone" do
      let(:message) { "iphone" }
      include_examples "sends_template", "sms_device_help_iphone_template_id"
    end
    describe "Sending a message detailing how to connect using Windows" do
      let(:message) { "windows" }
      include_examples "sends_template", "sms_device_help_windows_template_id"
    end
    describe "The message can contain other data" do
      let(:message) { "I would like to know more about Windows please" }
      include_examples "sends_template", "sms_device_help_windows_template_id"
    end
  end

  describe "the user already exists" do
    before :each do
      @user = FactoryBot.create(:user_details, contact: from_phone_number)
    end
    it "does not create another user" do
      expect {
        do_user_signup
      }.to_not change(WifiUser::User, :count)
    end
    it "sends an SMS to the user containing credentials" do
      do_user_signup
      expect(Services.notify_client).to have_received(:send_sms).with(
        phone_number: from_phone_number,
        template_id: "sms_credentials_template_id",
        personalisation: {
          login: @user.username,
          pass: @user.password,
        },
      )
    end
  end

  describe "The user is unreachable by phone" do
    before :each do
      response = double(body: "ValidationError", code: 200)
      allow(Services.notify_client).to receive(:send_sms).and_raise(Notifications::Client::BadRequestError.new(response))
    end
    it "does not create a user" do
      expect { do_user_signup }.to_not change(WifiUser::User, :count)
    end
  end

  describe "An invalid Bearer token" do
    let(:notify_token) { "invalid" }
    it "returns error code 401" do
      do_user_signup
      expect(last_response.body).to eq("")
      expect(last_response.status).to be(401)
    end
    it "does not create a user" do
      expect { do_user_signup }.to_not change(WifiUser::User, :count)
    end
    it "does not send any messages" do
      do_user_signup
      expect(Services.notify_client).to_not have_received(:send_email)
      expect(Services.notify_client).to_not have_received(:send_sms)
    end
  end

  describe "same sender phone number as the receiver" do
    let(:from_phone_number) { "+447700000000" }
    let(:to_phone_number) { "+447700000000" }
    it "does not create a user" do
      expect { do_user_signup }.to_not change(WifiUser::User, :count)
    end
    it "does not send any messages" do
      do_user_signup
      expect(Services.notify_client).to_not have_received(:send_email)
      expect(Services.notify_client).to_not have_received(:send_sms)
    end
    it "returns 200" do
      do_user_signup
      expect(last_response.body).to eq("")
      expect(last_response).to be_successful
    end
  end

  describe "repeated signups" do
    before :each do
      WifiUser::UseCase::RepetitiveSmsChecker::NUMBER_AND_MESSAGE_THRESHOLD.times { do_user_signup }
    end
    it "does not send any messages" do
      expect(Services.notify_client).to_not receive(:send_email)
      expect(Services.notify_client).to_not receive(:send_sms)
      do_user_signup
    end
    it "returns 200" do
      do_user_signup
      expect(last_response.body).to eq("")
      expect(last_response).to be_successful
    end
  end
end
