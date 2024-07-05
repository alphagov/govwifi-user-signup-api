describe Gdpr::UseCase::NotifyInactiveUsers do
  subject { described_class.new(user_details_gateway:) }

  let(:user_details_gateway) { double(notify_inactive_users: nil) }

  context "Given a user gateway" do
    it "calls notify_inactive_users on the gateway" do
      subject.execute
      expect(user_details_gateway).to have_received(:notify_inactive_users)
    end
  end
end
