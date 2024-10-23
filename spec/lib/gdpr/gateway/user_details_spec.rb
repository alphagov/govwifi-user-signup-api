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

  before :each do
    ENV["DO_NOT_REPLY"] = "do_not_reply_email_template_id"
    user_details.delete
  end

  context "Deleting old users" do
    context "Based on last_login" do
      context "Given no inactive users" do
        before do
          user_details.insert(username: "bob", contact: "+7391480025", last_login: Date.today)
          user_details.insert(username: "sally", contact: "sally@gov.uk", last_login: Date.today - 363)
        end

        it "does not delete any users" do
          expect { subject.delete_inactive_users }.not_to(change { user_details.count })
        end
      end

      context "Given inactive users" do
        before do
          allow(Common::Gateway::S3ObjectFetcher).to receive(:allow_list_regexp).and_return(valid_email_regexp)
          user_details.insert(username: "bob", contact: "+7391480025", last_login: Date.today)
          user_details.insert(username: "sally", contact: "+7391488825", created_at: Date.today - 363)
          user_details.insert(username: "george", contact: "george@gov.uk", last_login: Date.today - 367)
          user_details.insert(username: "Tony", contact: "tony@example.com", last_login: Date.today - 367)

          subject.delete_inactive_users
        end

        it "deletes only the old user records" do
          expect(user_details.select_map(:username)).to match_array(%w[bob sally])
        end

        it "notifies the deleted user with a valid email" do
          expect(notify_client).to have_received(:send_email).with(
            email_address: "george@gov.uk",
            template_id: "user_account_removed_email_id",
            personalisation: { inactivity_period: "12 months" },
            email_reply_to_id: "do_not_reply_email_template_id",
          ).once
        end
      end

      context "Given multiple inactive users" do
        before do
          user_details.insert(username: "bob", contact: "+7391481225", last_login: Date.today - 367)
          user_details.insert(username: "george", contact: "george@gov.uk", last_login: Date.today - 367)
        end

        it "deletes all the inactive users" do
          subject.delete_inactive_users
          expect(user_details.select_map(:username)).to be_empty
        end
      end

      context "Given a HEALTH user" do
        before do
          user_details.insert(username: "HEALTH", last_login: Date.today - 731)
        end

        it "does not delete the HEALTH user" do
          subject.delete_inactive_users
          expect(user_details.select_map(:username)).to include("HEALTH")
        end
      end

      context "Sending an emails throws an exception" do
        before :each do
          allow(Services.notify_client).to receive(:send_email).and_raise(UserSignupError)
          user_details.insert(username: "george", contact: "george@gov.uk", last_login: Date.today - 367)
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
          user_details.insert(username: "bob", contact: "bob@gov.uk", created_at: Date.today)
          user_details.insert(username: "sally", contact: "sally@gov.uk", created_at: Date.today - 300)
        end

        it "does not delete any user details" do
          expect { subject.delete_inactive_users }.not_to(change { user_details.count })
        end
      end

      context "Given one inactive user" do
        before do
          user_details.insert(username: "bob", contact: "bob@gov.uk", created_at: Date.today)
          user_details.insert(username: "sally", contact: "sally@gov.uk", created_at: Date.today - 300)
          user_details.insert(username: "george", contact: "george@gov.uk", created_at: Date.today - 368)
        end

        it "deletes only the old user record" do
          subject.delete_inactive_users
          expect(user_details.all.map { |s| s.fetch(:username) }).to eq(%w[bob sally])
        end
      end

      context "Given multiple inactive users" do
        before do
          user_details.insert(username: "bob", contact: "bob@gov.uk", created_at: Date.today - 370)
          user_details.insert(username: "george", contact: "george@gov.uk", created_at: Date.today - 380)
        end

        it "deletes all the inactive users" do
          subject.delete_inactive_users
          expect(user_details.all).to be_empty
        end

        context "Given the HEALTH user with an inactive created_at" do
          before do
            user_details.insert(username: "HEALTH", created_at: Date.today - 549)
          end

          it "does not delete the HEALTH user" do
            subject.delete_inactive_users
            expect(user_details.all.map { |s| s.fetch(:username) }).to include("HEALTH")
          end
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
    before do
      user_details.insert(username: "Kate", contact: "Kate@digital.cabinet-office.gov.uk", last_login: Date.today - 335)
      user_details.insert(username: "Rob", contact: "+07391491234", created_at: Date.today - 335)
      user_details.insert(username: "Adam", contact: "+07391491678", last_login: Date.today)
      user_details.insert(username: "Sim", contact: "sim@gov.uk", last_login: Date.today)
    end

    it "notifies inactive users" do
      subject.notify_inactive_users

      expect(notify_client).to have_received(:send_email).with(
        email_address: "Kate@digital.cabinet-office.gov.uk",
        template_id: "credentials_expiring_notification_email_id",
        personalisation: { inactivity_period: "11 months", username: "Kate" },
        email_reply_to_id: "do_not_reply_email_template_id",
      ).once

      expect(notify_client).to have_received(:send_sms).with(
        phone_number: "+07391491234",
        template_id: "credentials_expiring_notification_sms_id",
        personalisation: { inactivity_period: "11 months", username: "Rob" },
      ).once
    end

    it "does not notify active users" do
      expect(notify_client).not_to receive(:send_email).with(email_address: "sim@gov.uk")
      expect(notify_client).not_to receive(:send_sms).with(phone_number: "+07391491678")

      subject.notify_inactive_users
    end
  end
end
