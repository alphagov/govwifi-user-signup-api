describe WifiUser::UseCase::CheckUserIsSponsee do
  subject { described_class.new(allowlist_checker:) }

  let(:allowlist_checker) { double(execute: { success: true }) }
  let!(:sponsored_user) { FactoryBot.create(:user_details, :recent, :active, :sponsored) }

  before do
    @contact = sponsored_user.contact
    @sponsor = sponsored_user.sponsor
  end

  context "given user is sponsored" do
    it "returns true when sponsee has a valid sponsor email" do
      result = subject.execute(sponsored_user.contact)
      expect(result).to eq(true)
    end

    context "Invalid sponsor email" do
      let(:allowlist_checker) { double(execute: { success: false }) }

      it "returns false when sponsee has an invalid sponsor email" do
        result = subject.execute(sponsored_user.contact)
        expect(result).to eq(false)
      end
    end
  end

  context "given user does not have an account" do
    it "returns false when user cannot be found in database" do
      result = subject.execute("does_not_exist@example.com")
      expect(result).to eq(false)
    end
  end
end
