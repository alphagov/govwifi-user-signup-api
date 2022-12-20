describe WifiUser::UseCase::CheckUserIsSponsee do
  subject { described_class.new }

  let(:normal_user) { FactoryBot.create(:user_details, :recent, :active, :self_signed) }
  let(:sponsee_user) { FactoryBot.create(:user_details, :recent, :active, :sponsored) }

  before do
    @normal_user_contact = normal_user.contact
    @sponsee_contact = sponsee_user.contact
  end

  context "given user is sponsored" do
    it "returns true when sponsee has a valid sponsor email" do
      result = subject.execute(@sponsee_contact)
      expect(result).to eq(true)
    end
  end

  context "given user is not a sponsored" do
    it "returns false when user's contact email provided matches their sponsor email" do
      result = subject.execute(@normal_user_contact)
      expect(result).to eq(false)
    end
  end

  context "given user does not have an account" do
    it "returns false when user cannot be found in database" do
      result = subject.execute("does_not_exist@example.com")
      expect(result).to eq(false)
    end
  end
end
