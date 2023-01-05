describe WifiUser::UseCase::EmailJourneyHandler do
  include_context "fake notify"
  include_context "simple allow list"

  context "A new user from a government address" do
    it "creates a new user" do
      expect {
        WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
      }.to change(WifiUser::User, :count).by(1)
    end
    it "sends the credentials" do
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
      an_email_was_sent_with_template("email_self_signup_credentials_template_id")
    end
  end

  context "The user already exists" do
    before :each do
      WifiUser::User.create(contact: "test@gov.uk")
    end
    it "does not create a new user if one exists" do
      expect {
        WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
      }.to change(WifiUser::User, :count).by(0)
    end
    it "sends the credentials again" do
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
      an_email_was_sent_with_template("email_self_signup_credentials_template_id")
    end
  end

  context "the user is from a non-government address" do
    it "sends a rejection email" do
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@nongov.uk").execute
      an_email_was_sent_with_template("email_rejected_email_address_template_id")
    end
    it "does not create a new user" do
      expect {
        WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@nongov.uk").execute
      }.to change(WifiUser::User, :count).by(0)
    end
  end
end
