require "timecop"
describe Survey::UseCase::SendActiveUserSurveys do
  let(:year) { 2024 }
  let(:month) { 5 }
  let(:day) { 10 }
  let(:yesterday) { Time.local(year, month, day - 1, 9, 0, 0) }
  let(:today) { Time.local(year, month, day, 9, 0, 0) }
  let(:day_before_yesterday) { Time.local(year, month, day - 2, 9, 0, 0) }

  let(:client) { instance_double(Notifications::Client, send_email: nil, send_sms: nil) }
  before do
    Timecop.freeze(today)
    allow(Services).to receive(:notify_client).and_return(client)
  end
  after do
    Timecop.return
  end

  it "sends an email to a an active user" do
    user = FactoryBot.create(:user_details, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(client).to have_received(:send_email).with(template_id: "active-users-email-signup-survey-template",
                                                      email_address: user.contact)
    expect(client).to_not have_received(:send_sms)
  end

  it "sends an sms to a an active user" do
    user = FactoryBot.create(:user_details, :sms, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(client).to have_received(:send_sms).with(template_id: "active-users-mobile-signup-survey-template",
                                                    phone_number: user.contact)
    expect(client).to_not have_received(:send_email)
  end

  it "does not send a survey to users outside the window" do
    FactoryBot.create(:user_details, :sms, created_at: day_before_yesterday)
    FactoryBot.create(:user_details, :sms, created_at: today)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(client).to_not have_received(:send_email)
    expect(client).to_not have_received(:send_sms)
  end

  it "does not send a survey to users that haven't signed in" do
    FactoryBot.create(:user_details, :inactive, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(client).to_not have_received(:send_email)
  end

  it "sets the signup_survey_sent_at flag" do
    user = FactoryBot.create(:user_details, :sms, created_at: yesterday)
    expect {
      Survey::UseCase::SendActiveUserSurveys.execute
    }.to change {
      user.reload.signup_survey_sent_at
    }.from(nil).to(today)
  end

  context "Notify throws an error" do
    before :each do
      allow(client).to receive(:send_email).and_raise(StandardError)
      @user = FactoryBot.create(:user_details, created_at: yesterday)
    end
    it "logs the failure" do
      logger = instance_double(Logger, info: nil, warn: nil)
      Survey::UseCase::SendActiveUserSurveys.execute(logger:)
      expect(logger).to have_received(:warn).with(/Could not send survey/)
    end
    it "sets the signup_survey_sent_at flag" do
      expect {
        Survey::UseCase::SendActiveUserSurveys.execute
      }.to change {
        @user.reload.signup_survey_sent_at
      }.from(nil).to(Time.local(year, month, day, 9, 0, 0))
    end
  end
end
