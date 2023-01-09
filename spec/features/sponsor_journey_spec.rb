require_relative "./shared"

RSpec.describe App do
  include_context "fake notify"
  include_context "simple allow list"

  describe "POST /user-signup/sms-notification/notify" do
    before { skip "Temporarily disabled" }
    let(:email_request_headers) { { "HTTP_X_AMZ_SNS_MESSAGE_TYPE" => "Notification" } }
    let(:bucketName) { "mybucket" }
    let(:objectKey) { "mykey" }
    let(:sponsor_address) { "pete@gov.uk" }
    let(:type) { "Notification" }
    let(:messageId) { "123" }
    let(:request_body) do
      FactoryBot.create(:request_body,
                        from: sponsor_address,
                        to: "sponsor@gov.uk",
                        messageId:,
                        type:,
                        bucketName:,
                        objectKey:)
    end

    def do_user_signup
      post "/user-signup/email-notification", request_body.to_json, email_request_headers
    end

    def set_email(text_part: nil, html_part: nil, body: nil)
      mail = Mail.new
      mail.parts << Mail::Part.new(body: text_part) if text_part
      mail.parts << Mail::Part.new(content_type: "text/html; charset=UTF-8", body: html_part) if html_part
      mail.body = body if body
      Services.s3_client.put_object(bucket: bucketName, key: objectKey, body: mail.to_s)
    end

    def notify_has_sent_email_to(email_address)
      user = WifiUser::User.find(contact: email_address)
      expect(Services.notify_client).to have_received(:send_email).with(
        {
          email_address:,
          personalisation: {
            username: user.username,
            password: user.password,
            sponsor: sponsor_address,
          },
          template_id: "email_sponsored_credentials_template_id",
          email_reply_to_id: "do_not_reply_email_template_id",
        },
      )
    end

    def notify_has_sent_sms_to(phone_number)
      user = WifiUser::User.find(contact: phone_number)
      expect(Services.notify_client).to have_received(:send_sms).with(
        {
          phone_number:,
          personalisation: {
            login: user.username,
            pass: user.password,
          },
          template_id: "sms_credentials_template_id",
        },
      )
    end

    describe "A valid sponsor signs up users through email" do
      it "creates two new users" do
        set_email(body: "john@nongov.uk\nemma@elsewhere.uk")
        expect {
          do_user_signup
        }.to change(WifiUser::User, :count).by(2)
      end
      it "creates a new user with the correct parameters" do
        set_email(body: "john@nongov.uk")
        do_user_signup
        expect(WifiUser::User.find(contact: "john@nongov.uk", sponsor: sponsor_address)).to_not be(nil)
      end
      it "creates a new user, normalising the email address" do
        set_email(body: "  John Doe < john@nongov.uk  >  ")
        do_user_signup
        expect(WifiUser::User.find(contact: "john@nongov.uk")).to_not be(nil)
      end
      it "handles html multipart" do
        set_email(html_part: "<h1><b>john@nongov.uk</b></h1>")
        do_user_signup
        expect(WifiUser::User.find(contact: "john@nongov.uk")).to_not be(nil)
      end
      it "handles text multipart" do
        set_email(text_part: "john@nongov.uk")
        do_user_signup
        expect(WifiUser::User.find(contact: "john@nongov.uk")).to_not be(nil)
      end
      it "sends an email to all email recipients" do
        set_email(body: "john@nongov.uk\nemma@elsewhere.uk")
        do_user_signup
        notify_has_sent_email_to "john@nongov.uk"
        notify_has_sent_email_to "emma@elsewhere.uk"
      end
    end

    describe "A valid sponsor signs up users through SMS" do
      it "creates two new users" do
        set_email(body: "07701001111\n+447701002222")
        expect {
          do_user_signup
        }.to change(WifiUser::User, :count).by(2)
      end
      it "creates a new user with the correct parameters" do
        set_email(body: "+447701001111")
        do_user_signup
        expect(WifiUser::User.find(contact: "+447701001111", sponsor: sponsor_address)).to_not be(nil)
      end
      it "normalises phone numbers" do
        set_email(body: "07701001111")
        do_user_signup
        expect(WifiUser::User.find(contact: "+447701001111", sponsor: sponsor_address)).to_not be(nil)
      end
      it "sends SMSes to all users" do
        set_email(body: "07701001111\n+447701002222")
        do_user_signup
        notify_has_sent_sms_to("+447701002222")
        notify_has_sent_sms_to("+447701001111")
      end
    end
    describe "sending receipts" do
      it "sends a receipt to the sponsor (plural)" do
        set_email(body: "john@nongov.uk\n07701001111")
        do_user_signup
        expect(Services.notify_client).to have_received(:send_email).with(
          email_address: sponsor_address,
          personalisation: {
            number_of_accounts: 2,
            contacts: "john@nongov.uk\r\n+447701001111",
          },
          template_id: "email_sponsor_confirmation_plural_template_id",
          email_reply_to_id: "do_not_reply_email_template_id",
        )
      end
      it "sends a receipt to the sponsor (singular)" do
        set_email(body: "john@nongov.uk")
        do_user_signup
        expect(Services.notify_client).to have_received(:send_email).with(
          email_address: sponsor_address,
          personalisation: {
            contact: "john@nongov.uk",
          },
          template_id: "email_sponsor_confirmation_singular_template_id",
          email_reply_to_id: "do_not_reply_email_template_id",
        )
      end
      it "sends a receipt when a sponsee email has failed to send" do
        set_email(body: "07701001111\njohn@nongov.uk")
        response = double(body: "ValidationError", code: 200)
        allow(Services.notify_client).to receive(:send_email).and_raise(Notifications::Client::RequestError.new(response))
        allow(Services.notify_client).to receive(:send_sms).and_raise(Notifications::Client::RequestError.new(response))

        do_user_signup
        expect(Services.notify_client).to have_received(:send_email).with(
          email_address: sponsor_address,
          personalisation: {
            failedSponsees: "* +447701001111\n* john@nongov.uk",
          },
          template_id: "email_sponsor_confirmation_failed_template_id",
          email_reply_to_id: "do_not_reply_email_template_id",
        )
      end
    end

    describe "The sponsor is from a non-government email address" do
      let(:sponsor_address) { "pete@nongov.uk" }
      it "Does not create a user" do
        expect {
          do_user_signup
        }.to_not change(WifiUser::User, :count)
      end
      it "Does not send any emails" do
        expect(Services.notify_client).to_not have_received(:send_email)
      end
    end

    describe "invalid email address" do
      let(:sponsor_address) { "invalid@email@address" }
      it_behaves_like "rejects_email"
    end
    describe "invalid header" do
      let(:email_request_headers) do
        { "HTTP_X_AMZ_SNS_MESSAGE_TYPE" => "Invalid" }
      end
      include_examples "rejects_email"
    end
    describe "type is not a notification" do
      let(:type) { "SubscriptionConfirmation" }
      include_examples "rejects_email"
    end
    describe "messageId=AMAZON_SES_SETUP_NOTIFICATION" do
      let(:messageId) { "AMAZON_SES_SETUP_NOTIFICATION" }
      include_examples "rejects_email"
    end
  end
end
