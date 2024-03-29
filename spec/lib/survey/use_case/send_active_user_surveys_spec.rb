describe Survey::UseCase::SendActiveUserSurveys do
  let(:user_details_gateway) { double("gateway double", fetch_active: %i[user1 user2], mark_as_sent: nil) }
  let(:notifications_gateway) { double("notifications gateway", execute: :success) }

  subject do
    described_class.new(
      user_details_gateway:,
      notifications_gateway:,
    )
  end

  it "calls the user_details_gateway's fetch method" do
    subject.execute

    expect(user_details_gateway).to have_received(:fetch_active)
  end

  it "calls the notifications gateway with each value received" do
    subject.execute

    expect(notifications_gateway)
      .to have_received(:execute).with(:user1).ordered

    expect(notifications_gateway)
      .to have_received(:execute).with(:user2).ordered
  end

  it "calls the user_details_gateway's mark_as_sent method" do
    subject.execute

    expect(user_details_gateway).to have_received(:mark_as_sent).with(%i[user1 user2])
  end
end
