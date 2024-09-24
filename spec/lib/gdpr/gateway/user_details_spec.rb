describe Gdpr::Gateway::Userdetails do
  include_context "fake notify"

  let(:templates) do
    [
      instance_double(Notifications::Client::Template, name: "credentials_expiring_notification_email", id: "credentials_expiring_notification_email_id"),
      instance_double(Notifications::Client::Template, name: "credentials_expiring_notification_sms", id: "credentials_expiring_notification_sms_id"),
      instance_double(Notifications::Client::Template, name: "user_account_removed_sms", id: "user_account_removed_sms_id"),
      instance_double(Notifications::Client::Template, name: "user_account_removed_email", id: "user_account_removed_email_id"),
      instance_double(Notifications::Client::Template, name: "active_users_signup_survey_sms", id: "active_users_signup_survey_sms_id"),
      instance_double(Notifications::Client::Template, name: "active_users_signup_survey_email", id: "active_users_signup_survey_email_id"),
    ]
  end
  let(:user_details) { DB[:userdetails] }
  let(:notify_client) { Services.notify_client }
  let(:valid_email_regexp) { /^[A-Za-z0-9._%+-]+@gov\.uk$/ }

  let(:year) { 2024 }
  let(:month) { 12 }
  let(:day) { 10 }
  let(:hour) { 18 }
  let(:now) { Time.new(year, month, day, hour, 0, 0) }
  let(:notify_client) { Services.notify_client }
  let(:inactive_months) { 3 }

  after do
    Timecop.return
  end

  before :each do
    ENV["DO_NOT_REPLY"] = "do_not_reply_email_template_id"
    user_details.delete
    Timecop.freeze(now)
  end

  context "#users_to_delete" do
    context "Based on last_login" do
      context "Given no inactive users" do
        before do
          FactoryBot.create(:user_details, last_login: Time.new(year, month - inactive_months, day + 1, 12, 0, 0))
          FactoryBot.create(:user_details, :sms, last_login: Time.new(year, month - inactive_months, day + 1, 12, 0, 0))
        end

        it "does not delete any users" do
          expect { subject.delete_inactive_users(inactive_months:) }.not_to change(WifiUser::User, :count)
        end
        it "does not send any messages" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to_not have_received(:send_email)
          expect(notify_client).to_not have_received(:send_sms)
        end
      end
      context "Given inactive users" do
        before do
          FactoryBot.create(:user_details, contact: "dave@gov.uk", last_login: Time.new(year, month - inactive_months, day, 12, 0, 0))
          FactoryBot.create(:user_details, contact: "+447700000000", last_login: Time.new(year, month - inactive_months, day, 12, 0, 0))
        end
        it "deletes the users" do
          expect { subject.delete_inactive_users(inactive_months:) }.to change(WifiUser::User, :count).by(-2)
        end
        it "sends an email" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to have_received(:send_email).with(
            email_address: "dave@gov.uk",
            template_id: "user_account_removed_email_id",
            personalisation: { inactivity_period: "#{inactive_months} months" },
            email_reply_to_id: "do_not_reply_email_template_id",
          ).once
        end
        it "sends an sms" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to have_received(:send_sms).with(
            phone_number: "+447700000000",
            template_id: "user_account_removed_sms_id",
            personalisation: { inactivity_period: "#{inactive_months} months" },
          ).once
        end
      end

      context "Given a HEALTH user" do
        before do
          FactoryBot.create(:user_details, :health_user, last_login: Time.new(year - 10, month, day, 12, 0, 0))
        end

        it "does not delete the HEALTH user" do
          subject.delete_inactive_users
          expect(WifiUser::User.find(username: "HEALTH")).to_not be nil
        end
      end

      context "Sending an email throws an exception" do
        before :each do
          allow(Services.notify_client).to receive(:send_email).and_raise(UserSignupError)
          FactoryBot.create(:user_details, contact: "dave@gov.uk", last_login: Time.new(year - 10, month, day, 12, 0, 0))
        end
        it "still deletes the user" do
          expect { subject.delete_inactive_users }.to change { user_details.count }.by(-1)
          expect(Services.notify_client).to have_received(:send_email)
        end
      end
    end

    context "Based on created_at" do
      context "Given no inactive users" do
        before do
          FactoryBot.create(:user_details, :not_logged_in,
                            created_at: Time.new(year, month - inactive_months, day + 1, 12, 0, 0))
          FactoryBot.create(:user_details, :not_logged_in, :sms,
                            created_at: Time.new(year, month - inactive_months, day + 1, 12, 0, 0))
        end

        it "does not delete any users" do
          expect { subject.delete_inactive_users(inactive_months:) }.not_to change(WifiUser::User, :count)
        end
        it "does not send any messages" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to_not have_received(:send_email)
          expect(notify_client).to_not have_received(:send_sms)
        end
      end
      context "Given inactive users" do
        before do
          FactoryBot.create(:user_details, :not_logged_in, contact: "dave@gov.uk",
                                                           created_at: Time.new(year, month - inactive_months, day, 12, 0, 0))
          FactoryBot.create(:user_details, :not_logged_in, contact: "+447700000000",
                                                           created_at: Time.new(year, month - inactive_months, day, 12, 0, 0))
        end

        it "deletes the users" do
          expect { subject.delete_inactive_users(inactive_months:) }.to change(WifiUser::User, :count).by(-2)
        end
        it "sends an email" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to have_received(:send_email).with(
            email_address: "dave@gov.uk",
            template_id: "user_account_removed_email_id",
            personalisation: { inactivity_period: "#{inactive_months} months" },
            email_reply_to_id: "do_not_reply_email_template_id",
          ).once
        end
        it "sends an sms" do
          subject.delete_inactive_users(inactive_months:)
          expect(notify_client).to have_received(:send_sms).with(
            phone_number: "+447700000000",
            template_id: "user_account_removed_sms_id",
            personalisation: { inactivity_period: "#{inactive_months} months" },
          ).once
        end
      end
      context "Given a HEALTH user" do
        before do
          FactoryBot.create(:user_details, :health_user, last_login: Time.new(year - 10, month, day, 12, 0, 0))
        end

        it "does not delete the HEALTH user" do
          subject.delete_inactive_users
          expect(WifiUser::User.find(username: "HEALTH")).to_not be nil
        end
      end
    end
  end

  context "Obfuscating user details" do
    context "Inactive sponsor" do
      before do
        user_details.insert(username: "bob", sponsor: "sally@gov.uk")
      end

      it "obfuscates the sponsor if the sponsor user record does not exist" do
        subject.obfuscate_sponsors
        expect(user_details.where(username: "bob").get(:sponsor)).to eq("user@gov.uk")
      end

      it "does not obfuscate the sponsor more than once" do
        user_details.insert(
          username: "sally",
          contact: "sally@gov.uk",
          sponsor: "user@gov.uk",
          updated_at: Date.today,
        )

        expect {
          subject.obfuscate_sponsors
        }.not_to(change { user_details.where(username: "sally").get(:updated_at) })
      end
    end

    context "Active sponsor" do
      before do
        user_details.insert(username: "bob", sponsor: "sally@gov.uk")
        user_details.insert(username: "sally", contact: "sally@gov.uk", sponsor: "sally@gov.uk")
      end

      it "does not obfuscate the sponsor if the sponsor user record exists" do
        subject.obfuscate_sponsors
        expect(user_details.where(username: "bob").get(:sponsor)).to eq("sally@gov.uk")
      end
    end

    context "Given nobody sponsored the user" do
      context "Given a mobile signup" do
        it "does not obfuscate the sponsor field" do
          user_details.insert(username: "fred", contact: "0839038939", sponsor: "0839038939")
          subject.obfuscate_sponsors
          expect(user_details.where(username: "fred").get(:sponsor)).to eq("0839038939")
        end
      end

      context "Given an email signup" do
        it "does not obfuscate the sponsor field" do
          user_details.insert(username: "fred", contact: "fred@example.com", sponsor: "fred@example.com")
          subject.obfuscate_sponsors
          expect(user_details.where(username: "fred").get(:sponsor)).to eq("fred@example.com")
        end
      end
    end
  end

  context "Notifying inactive users" do
    describe "#notify_inactive_users" do
      it "notifies an inactive user by email" do
        user = FactoryBot.create(:user_details, last_login: Time.new(year, month - inactive_months, day, 12, 0, 0))
        subject.notify_inactive_users(inactive_months:)
        expect(notify_client).to have_received(:send_email).with(
          email_address: user.contact,
          template_id: "credentials_expiring_notification_email_id",
          personalisation: { inactivity_period: "3 months", username: user.username },
          email_reply_to_id: "do_not_reply_email_template_id",
        ).once
      end
      it "notifies an inactive user by sms" do
        user = FactoryBot.create(:user_details, :sms, last_login: Time.new(year, month - 3, day, 12, 0, 0))
        subject.notify_inactive_users(inactive_months:)
        expect(notify_client).to have_received(:send_sms).with(
          phone_number: user.contact,
          template_id: "credentials_expiring_notification_sms_id",
          personalisation: { inactivity_period: "3 months", username: user.username },
        ).once
      end
      it "does not notify users that are not exactly the given months inactive" do
        FactoryBot.create(:user_details, last_login: Time.new(year, month - 3, day - 1, 12, 0, 0))
        FactoryBot.create(:user_details, last_login: Time.new(year, month - 3, day + 1, 12, 0, 0))
        FactoryBot.create(:user_details, :sms, last_login: Time.new(year, month - 3, day - 1, 12, 0, 0))
        FactoryBot.create(:user_details, :sms, last_login: Time.new(year, month - 3, day + 1, 12, 0, 0))
        subject.notify_inactive_users(inactive_months:)
        expect(notify_client).to_not have_received(:send_email)
        expect(notify_client).to_not have_received(:send_sms)
      end
      it "does not notify the HEALTH user" do
        FactoryBot.create(:user_details, :health_user, last_login: Time.new(year, month - 3, day, 12, 0, 0))
        subject.notify_inactive_users(inactive_months:)
        expect(notify_client).to_not have_received(:send_email)
      end
    end
  end
end
