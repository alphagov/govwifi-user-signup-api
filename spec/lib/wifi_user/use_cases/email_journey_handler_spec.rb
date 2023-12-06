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
      expect(WifiUser::EmailSender).to receive(:send_signup_instructions)
        .with(have_attributes(contact: "test@gov.uk"))
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
    end
  end

  context "The user already exists" do
    before :each do
      @user = WifiUser::User.create(contact: "test@gov.uk")
    end
    it "does not create a new user if one exists" do
      expect {
        WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
      }.to change(WifiUser::User, :count).by(0)
    end
    it "sends the credentials again" do
      expect(WifiUser::EmailSender).to receive(:send_signup_instructions)
        .with(have_attributes(contact: @user.contact, username: @user.username, password: @user.password))
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@gov.uk").execute
    end
  end

  context "the user is from a non-government address" do
    it "sends a rejection email" do
      expect(WifiUser::EmailSender).to receive(:send_rejected_email_address)
        .with("test@nongov.uk")
      WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@nongov.uk").execute
    end
    it "does not create a new user" do
      expect {
        WifiUser::UseCase::EmailJourneyHandler.new(from_address: "test@nongov.uk").execute
      }.to change(WifiUser::User, :count).by(0)
    end
  end
end
