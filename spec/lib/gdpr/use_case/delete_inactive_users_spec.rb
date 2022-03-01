describe Gdpr::UseCase::DeleteInactiveUsers do
  subject { described_class.new(user_details_gateway:) }

  let(:user_details_gateway) { double(delete_users: nil) }

  context "Given a user gateway" do
    it "calls delete_users on the gateway" do
      subject.execute
      expect(user_details_gateway).to have_received(:delete_users)
    end
  end
end
