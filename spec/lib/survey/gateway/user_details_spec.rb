describe Survey::Gateway::UserDetails do
  let(:user_details) { DB[:userdetails] }

  before do
    user_details.delete
  end

  describe "#fetch_for_active" do
    context "when the user has been created in the last 24 hours" do
      context "but has not logged in" do
        let(:recent_inactive_user) do
          FactoryBot.create(
            :user_details,
            :self_signed,
            :recent,
            :inactive,
          )
        end

        it "does not include them" do
          expect(subject.fetch_for_active).to_not include(recent_inactive_user)
        end
      end

      context "and has logged in" do
        let!(:recent_user) do
          FactoryBot.create(
            :user_details,
            :self_signed,
            :recent,
            :active,
          )
        end

        it "includes them" do
          expect(subject.fetch_for_active).to include(recent_user)
        end

        it "only returns 25% of users" do
          FactoryBot.create_list(
            :user_details,
            100,
            :self_signed,
            :recent,
            :active,
          )

          expect(subject.fetch_for_active.count).to eq 26 # 25 + the :recent_user
        end
      end
    end

    context "when the user was created more than 24 hours ago" do
      let!(:idle_user) do
        FactoryBot.create(
          :user_details,
          :self_signed,
          :active,
          created_at: Time.now - 42 * 3600 * 24,
        )
      end

      it "does not include them" do
        expect(subject.fetch_for_active).to_not include(idle_user)
      end
    end

    context "when the user has already been sent the survey" do
      let!(:surveyed_user) do
        FactoryBot.create(
          :user_details,
          :signup_survey_sent,
          :recent,
          :active,
        )
      end

      it "does not include them" do
        expect(subject.fetch_for_active).to_not include(surveyed_user)
      end
    end

    context "when the user is sponsored" do
      # FIXME: the default user factory is a sponsored user, an explicit trait would be nice
      let!(:sponsored_user) { FactoryBot.create(:user_details, :recent, :active, :sponsored) }

      it "does not include them" do
        expect(subject.fetch_for_active).to_not include(sponsored_user)
      end
    end
  end

  describe "#fetch_for_inactive" do
    context "when the user has been created less than 14 days ago" do
      context "but has not logged in" do
        let(:recent_inactive_user) do
          FactoryBot.create(
            :user_details,
            :self_signed,
            :recent,
            :inactive,
          )
        end

        it "does not include them" do
          expect(subject.fetch_for_inactive).to_not include(recent_inactive_user)
        end
      end
    end

    context "when the user has been created 14 days ago" do
      context "and has not logged in" do
        let!(:idle_user) do
          FactoryBot.create(
            :user_details,
            :self_signed,
            :inactive,
            :idle_survey_target,
          )
        end

        it "includes them" do
          expect(subject.fetch_for_inactive).to include(idle_user)
        end

        it "only returns 25% of users" do
          FactoryBot.create_list(
            :user_details,
            100,
            :self_signed,
            :inactive,
            :idle_survey_target,
          )

          expect(subject.fetch_for_inactive.count).to eq 26 # 25 + the :idle_user
        end
      end

      context "and has logged in" do
        let!(:idle_user) do
          FactoryBot.create(
            :user_details,
            :self_signed,
            :active,
            :idle_survey_target,
          )
        end

        it "does not include them" do
          expect(subject.fetch_for_inactive).to_not include(idle_user)
        end
      end
    end

  end

  describe "#mark_as_sent" do
    let!(:user) { FactoryBot.create(:user_details, :self_signed, :active) }

    before do
      @query = subject.fetch_for_active
    end

    it "updates the survey_sent_at attribute" do
      expect { subject.mark_as_sent(@query) }
        .to(change { user.reload.signup_survey_sent_at })
    end
  end
end
