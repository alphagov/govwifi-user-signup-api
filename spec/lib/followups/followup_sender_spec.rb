require "timecop"

describe Followups::FollowupSender do
  let(:user_details) { DB[:userdetails] }
  let(:notify_client) { instance_double(Notifications::Client, send_email: true, send_sms: true) }
  let(:year) { 2024 }
  let(:month) { 5 }
  let(:day) { 10 }
  let(:one_day_ago) { Date.new(year, month, day - 1) }
  let(:two_days_ago) { Date.new(year, month, day - 2) }

  before :each do
    user_details.delete
    Timecop.freeze(Time.local(year, month, day, 9, 0, 0))
    allow(Services).to receive(:notify_client).and_return(notify_client)
  end

  after do
    Timecop.return
  end

  context "Given no inactive users" do
    before do
      FactoryBot.create(:user_details, :not_logged_in, created_at: one_day_ago)
    end
    it "does not send an email" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to_not have_received(:send_email)
    end
  end
  context "Given a number of  inactive users" do
    before do
      FactoryBot.create(:user_details, :not_logged_in, created_at: two_days_ago)
      FactoryBot.create(:user_details, :not_logged_in, created_at: one_day_ago)
      FactoryBot.create(:user_details, :not_logged_in, created_at: two_days_ago)
      FactoryBot.create(:user_details, :sms, :not_logged_in, created_at: two_days_ago)
      FactoryBot.create(:user_details, :sms, :not_logged_in, created_at: one_day_ago)
      FactoryBot.create(:user_details, :sms, :not_logged_in, created_at: two_days_ago)
    end
    it "sends two emails and two sms messages" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to have_received(:send_email).twice
      expect(notify_client).to have_received(:send_sms).twice
    end
  end
  context "given an inactive user" do
    let(:contact) { "inactive@gov.uk" }
    before do
      FactoryBot.create(:user_details, :not_logged_in, contact:, created_at: two_days_ago)
    end
    it "sends an email with the appropriate parameters" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to have_received(:send_email).with(
        email_address: contact,
        template_id: "email_followup_template_id",
        email_reply_to_id: "do_not_reply_email_template_id",
      )
    end
    it "does not send the emails twice" do
      Followups::FollowupSender.send_messages
      Followups::FollowupSender.send_messages
      expect(notify_client).to have_received(:send_email).once
    end
    it "sets the followup_sent_at attribute" do
      expect {
        Followups::FollowupSender.send_messages
      }.to change {
        WifiUser::User.first(contact:).followup_sent_at
      }.from(nil).to(Time.now)
    end
  end
  context "Given inactive sponsored users" do
    before do
      FactoryBot.create(:user_details, :sponsored, :not_logged_in, created_at: two_days_ago)
      FactoryBot.create(:user_details, :sponsored, :not_logged_in, :sms, created_at: two_days_ago)
    end
    it "does not send the followup message" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to_not have_received(:send_email)
      expect(notify_client).to_not have_received(:send_sms)
    end
  end
  context "Given an inactive user who signed up using SMS" do
    let(:contact) { "+447700000000" }
    before do
      FactoryBot.create(:user_details, :sms, :not_logged_in, contact:, created_at: two_days_ago)
    end
    it "sends an SMS using the correct parameters" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to have_received(:send_sms).with(
        phone_number: contact,
        template_id: "sms_followup_template_id",
      )
    end
  end
end
