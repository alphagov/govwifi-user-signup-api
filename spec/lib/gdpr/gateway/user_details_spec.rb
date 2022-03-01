describe Gdpr::Gateway::Userdetails do
  let(:user_details) { DB[:userdetails] }

  before { user_details.delete }

  context "Deleting old users" do
    context "Based on last_login" do
      context "Given no inactive users" do
        before do
          user_details.insert(username: "bob", last_login: Date.today)
          user_details.insert(username: "sally", last_login: Date.today - 729)
        end

        it "does not delete any users" do
          expect { subject.delete_users }.not_to(change { user_details.count })
        end
      end

      context "Given one inactive user" do
        before do
          user_details.insert(username: "bob", last_login: Date.today)
          user_details.insert(username: "sally", created_at: Date.today - 729)
          user_details.insert(username: "george", last_login: Date.today - 731)
        end

        it "does deletes only the old user record" do
          subject.delete_users
          expect(user_details.all.map { |s| s.fetch(:username) }).to eq(%w[bob sally])
        end
      end

      context "Given multiple inactive user" do
        before do
          user_details.insert(username: "bob", last_login: Date.today - 831)
          user_details.insert(username: "george", last_login: Date.today - 731)
        end

        it "deletes all the inactive users" do
          subject.delete_users
          expect(user_details.all.map { |s| s.fetch(:username) }).to be_empty
        end

        context "Given a HEALTH user" do
          context "Given the HEALTH user with an inactive last_login" do
            before do
              user_details.insert(username: "HEALTH", last_login: Date.today - 731)
            end

            it "does not delete the HEALTH user" do
              subject.delete_users
              expect(user_details.all.map { |s| s.fetch(:username) }).to include("HEALTH")
            end
          end
        end
      end
    end

    context "Based on created_at" do
      context "Given no inactive users" do
        before do
          user_details.insert(username: "bob", created_at: Date.today)
          user_details.insert(username: "sally", created_at: Date.today - 729)
        end

        it "does not delete any user details" do
          expect { subject.delete_users }.not_to(change { user_details.count })
        end
      end

      context "Given one inactive user" do
        before do
          user_details.insert(username: "bob", created_at: Date.today)
          user_details.insert(username: "sally", created_at: Date.today - 729)
          user_details.insert(username: "george", created_at: Date.today - 731)
        end

        it "does deletes only the old user record" do
          subject.delete_users
          expect(user_details.all.map { |s| s.fetch(:username) }).to eq(%w[bob sally])
        end
      end

      context "Given multiple inactive user" do
        before do
          user_details.insert(username: "bob", created_at: Date.today - 831)
          user_details.insert(username: "george", created_at: Date.today - 731)
        end

        it "deletes all the inactive users" do
          subject.delete_users
          expect(user_details.all).to be_empty
        end

        context "Given the HEALTH user with an inactive created_at" do
          before do
            user_details.insert(username: "HEALTH", created_at: Date.today - 549)
          end

          it "does not delete the HEALTH user" do
            subject.delete_users
            expect(user_details.all.map { |s| s.fetch(:username) }).to include("HEALTH")
          end
        end
      end
    end
  end

  context "obfuscate user details" do
    context "inactive sponsor" do
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

    context "active sponsor" do
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
end
