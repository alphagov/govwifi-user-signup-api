describe WifiUser::UseCase::SponsorJourneyHandler do
  include_context "fake notify"
  include_context "simple allow list"

  let(:bucket_name) { "mybucket" }
  let(:object_key) { "object_key" }
  let(:raw_sponsor_address) { "pete <pete@gov.uk>" }
  let(:sponsor_address) { Mail::Address.new(raw_sponsor_address).address }
  let(:type) { "Notification" }
  let(:messageId) { "123" }
  let(:request_body) do
    FactoryBot.create(:request_body,
                      from: raw_sponsor_address,
                      to: "sponsor@gov.uk",
                      messageId:,
                      type:,
                      bucketName: bucket_name,
                      objectKey: object_key)
  end
  let(:sns_message) { WifiUser::SnsMessage.new(body: request_body.to_json) }

  context "the user is from a non-government address" do
    let(:raw_sponsor_address) { "test@nongov.uk" }
    it "raises an error" do
      expect {
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      }.to raise_error(/Unsuccessful sponsor signup attempt/)
    end
    it "does not create a new user" do
      expect {
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      }.to raise_error.and change(WifiUser::User, :count).by(0)
    end
  end

  context "there are no sponsees" do
    before :each do
      write_email_to_s3(body: "something\nsomething else\nnothing", bucket_name:, object_key:)
    end
    it "raises an error" do
      expect {
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      }.to raise_error(/Unable to find sponsees:/)
    end
    it "does not create a new user" do
      expect {
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      }.to raise_error.and change(WifiUser::User, :count).by(0)
    end
  end

  context "successful sponsoring" do
    before :each do
      write_email_to_s3(body: "something\n 077 01 00 1111\n  dave@nongov.uk ", bucket_name:, object_key:)
    end
    it "creates two users" do
      expect {
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      }.to change(WifiUser::User, :count).by(2)
    end
    it "creates users with the correct parameters" do
      WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      expect(WifiUser::User.find(contact: "+447701001111", sponsor: sponsor_address)).to_not be_nil
      expect(WifiUser::User.find(contact: "dave@nongov.uk", sponsor: sponsor_address)).to_not be_nil
    end
    it "sends an email to the sponsee" do
      expect(WifiUser::EmailSender).to receive(:send_sponsor_email)
        .with(raw_sponsor_address, have_attributes(contact: "dave@nongov.uk", sponsor: sponsor_address)).and_return true
      WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
    end
    it "sends an sms to the sponsee" do
      expect(WifiUser::SMSSender).to receive(:send_sponsor_sms)
        .with(have_attributes(contact: "+447701001111", sponsor: sponsor_address)).and_return true
      WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
    end
    it "sends a confirmation email to the sponsor" do
      expect(WifiUser::EmailSender).to receive(:send_sponsor_confirmation_plural)
        .with(sponsor_address, match_array([have_attributes(contact: "dave@nongov.uk", sponsor: sponsor_address),
                                            have_attributes(contact: "+447701001111", sponsor: sponsor_address)]))
      WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
    end
    context "a user already exists but has not been sponsored" do
      before :each do
        @user = WifiUser::User.create(contact: "test@gov.uk")
        write_email_to_s3(body: "test@gov.uk", bucket_name:, object_key:)
      end
      it "does not create a new user" do
        expect {
          WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
        }.to_not change(WifiUser::User, :count)
      end
      it "sends the credentials of the existing user" do
        expect(WifiUser::EmailSender).to receive(:send_sponsor_email)
                                           .with(raw_sponsor_address, have_attributes(contact: "test@gov.uk",
                                                                                      sponsor: "test@gov.uk",
                                                                                      password: @user.password))
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      end
    end
    context "only one sponsee" do
      before :each do
        write_email_to_s3(body: "dave@nongov.uk", bucket_name:, object_key:)
      end
      it "sends a singular confirmation email to the sponsor" do
        expect(WifiUser::EmailSender).to receive(:send_sponsor_confirmation_singular)
          .with(sponsor_address, have_attributes(contact: "dave@nongov.uk", sponsor: sponsor_address))
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      end
    end
    context "A sponsee cannot be contacted" do
      before :each do
        error = Notifications::Client::BadRequestError.new(double(body: "ValidationError", code: 200))
        allow(WifiUser::EmailSender).to receive(:send_sponsor_email).and_raise error
        allow(WifiUser::SMSSender).to receive(:send_sponsor_sms).and_raise error
      end
      it "sends a failure confirmation email to the sponsor" do
        expect(WifiUser::EmailSender).to receive(:send_sponsor_failed_confirmation_email)
          .with(sponsor_address, match_array([have_attributes(contact: "dave@nongov.uk", sponsor: sponsor_address),
                                              have_attributes(contact: "+447701001111", sponsor: sponsor_address)]))
        WifiUser::UseCase::SponsorJourneyHandler.new(sns_message:).execute
      end
    end
  end
end
