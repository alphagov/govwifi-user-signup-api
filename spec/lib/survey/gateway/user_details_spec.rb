describe Survey::Gateway::UserDetails do
  let(:user_details) { DB[:userdetails] }

  before do
    user_details.delete
  end

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
        expect(subject.fetch).to_not include(recent_inactive_user)
      end
    end

    context "and has logged in" do
      let(:recent_user) do
        FactoryBot.create(
          :user_details,
          :self_signed,
          :recent,
          :active,
        )
      end

      it "includes them" do
        expect(subject.fetch).to include(recent_user)
      end
    end
  end

  context "when the user was created more than 24 hours ago" do
    let(:old_user) do
      FactoryBot.create(
        :user_details,
        :self_signed,
        :active,
        created_at: Time.now - 42 * 3600 * 24,
      )
    end

    it "does not include them" do
      expect(subject.fetch).to_not include(old_user)
    end
  end

  context "when the user has already been sent the survey" do
    let(:surveyed_user) do
      FactoryBot.create(
        :user_details,
        :signup_survey_sent,
        :recent,
        :active,
      )
    end

    it "does not include them" do
      expect(subject.fetch).to_not include(surveyed_user)
    end
  end

  context "when the user is sponsored" do
    # FIXME: the default user factory is a sponsored user, an explicit trait would be nice
    let(:sponsored_user) { FactoryBot.create(:user_details, :recent, :active, :sponsored) }

    it "does not include them" do
      expect(subject.fetch).to_not include(sponsored_user)
    end
  end
end
