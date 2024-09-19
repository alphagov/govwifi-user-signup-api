require "timecop"

describe Followups::FollowupSender do
  include_context "fake notify"

  let(:templates) do
    [
      instance_double(Notifications::Client::Template, name: "followup_email", id: "followup_email_id"),
      instance_double(Notifications::Client::Template, name: "followup_sms", id: "followup_sms_id"),
    ]
  end

  let(:user_details) { DB[:userdetails] }
  let(:notify_client) { Services.notify_client }
  let(:year) { 2024 }
  let(:month) { 5 }
  let(:day) { 10 }
  let(:one_day_ago) { Time.local(year, month, day - 1, 13, 0, 0) }
  let(:two_days_ago) { Time.local(year, month, day - 2, 13, 0, 0) }
  let(:notify_client) { Services.notify_client }

  before :each do
    user_details.delete
    Timecop.freeze(Time.local(year, month, day, 18, 0, 0))
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
    it "sends two emails and no sms messages" do
      Followups::FollowupSender.send_messages
      expect(notify_client).to have_received(:send_email).twice
      expect(notify_client).to_not have_received(:send_sms)
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
        template_id: "followup_email_id",
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
end
