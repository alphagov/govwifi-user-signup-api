describe Survey::UseCase::SendActiveUserSurveys do
  include_context "fake notify"

  let(:templates) do
    [
      instance_double(Notifications::Client::Template, name: "active_users_signup_survey_email", id: "active_users_signup_survey_email_id"),
      instance_double(Notifications::Client::Template, name: "active_users_signup_survey_sms", id: "active_users_signup_survey_sms_id"),
    ]
  end

  let(:year) { 2024 }
  let(:month) { 5 }
  let(:day) { 10 }
  let(:yesterday) { Time.local(year, month, day - 1, 9, 0, 0) }
  let(:today) { Time.local(year, month, day, 9, 0, 0) }
  let(:day_before_yesterday) { Time.local(year, month, day - 2, 9, 0, 0) }

  before do
    Timecop.freeze(today)
  end
  after do
    Timecop.return
  end

  it "sends an email to a an active user" do
    user = FactoryBot.create(:user_details, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(Services.notify_client).to have_received(:send_email).with(template_id: "active_users_signup_survey_email_id",
                                                                      email_address: user.contact)
    expect(Services.notify_client).to_not have_received(:send_sms)
  end

  it "sends an sms to a an active user" do
    user = FactoryBot.create(:user_details, :sms, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(Services.notify_client).to have_received(:send_sms).with(template_id: "active_users_signup_survey_sms_id",
                                                                    phone_number: user.contact)
    expect(Services.notify_client).to_not have_received(:send_email)
  end

  it "does not send a survey to users outside the window" do
    FactoryBot.create(:user_details, :sms, created_at: day_before_yesterday)
    FactoryBot.create(:user_details, :sms, created_at: today)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(Services.notify_client).to_not have_received(:send_email)
    expect(Services.notify_client).to_not have_received(:send_sms)
  end

  it "does not send a survey to users that haven't signed in" do
    FactoryBot.create(:user_details, :inactive, created_at: yesterday)
    Survey::UseCase::SendActiveUserSurveys.execute
    expect(Services.notify_client).to_not have_received(:send_email)
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
      allow(Services.notify_client).to receive(:send_email).and_raise(UserSignupError)
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
