describe Survey::Gateway::Surveys do
  let(:user_details) { DB[:userdetails] }
  before do
    user_details.delete
  end

  context "Sending active user serveys" do
    context "Old user" do
    end

#     context "Sponsored user" do
#       before { FactoryBot.create(:user_details) }
#
#       it "does not send survey" do
#         expect(true).to be(true)
#         # expect { subject.send_signup_surveys }.to(change { user.signup_survey_sent_at })
#       end
#     end

    context "Email user" do
      let(:user) { FactoryBot.create(:user_details, :self_signed) }

      it "sends survey" do
        expect { subject.send_signup_surveys }.to(change { user.reload.signup_survey_sent_at })
      end
    end
#
#     context "Email user - survey already sent" do
#       let(:user) { FactoryBot.create(:user_details, :signup_survey_sent) }
#       it "does not send survey" do
#          expect { subject.send_signup_surveys }.not_to(change { user.reload.signup_survey_sent_at })
#       end
#     end
#
#     context "Email user - old" do
#       let(:user) { FactoryBot.create(:user_details, :signup_survey_sent) }
#
#       it "does not send survey" do
#         expect { subject.send_signup_surveys }.not_to(change { user.reload.signup_survey_sent_at })
#       end
#     end
#
#     context "Mobile user" do
#       let(:user) { FactoryBot.create(:user_details, :sms) }
#
#       it "does not? send survey" do
#         expect { subject.send_signup_surveys }.not_to(change { user.reload.signup_survey_sent_at })
#       end
#     end
  end

  #   context "Based on last_login" do
  #     context "Given no inactive users" do
  #       before do
  #         user_details.insert(username: "bob", last_login: Date.today)
  #         user_details.insert(username: "sally", last_login: Date.today - 364)
  #       end
  #
  #       it "does not delete any users" do
  #         expect { subject.delete_users }.not_to(change { user_details.count })
  #       end
  #     end
  #
  #     context "Given one inactive user" do
  #       before do
  #         user_details.insert(username: "bob", last_login: Date.today)
  #         user_details.insert(username: "george", last_login: Date.today - 366)
  #       end
  #
  #       it "does deletes only the old user record" do
  #         subject.delete_users
  #         expect(user_details.all.map { |s| s.fetch(:username) }).to eq(%w[bob])
  #       end
  #     end
  #
  #     context "Given multiple inactive user" do
  #       before do
  #         user_details.insert(username: "bob", last_login: Date.today - 466)
  #         user_details.insert(username: "george", last_login: Date.today - 366)
  #       end
  #
  #       it "deletes all the inactive users" do
  #         subject.delete_users
  #         expect(user_details.all.map { |s| s.fetch(:username) }).to be_empty
  #       end
  #
  #       context "Given a HEALTH user" do
  #         context "Given the HEALTH user with an inactive last_login" do
  #           before do
  #             user_details.insert(username: "HEALTH", last_login: Date.today - 366)
  #           end
  #
  #           it "does not delete the HEALTH user" do
  #             subject.delete_users
  #             expect(user_details.all.map { |s| s.fetch(:username) }).to include("HEALTH")
  #           end
  #         end
  #       end
  #     end
  #   end
  # end
end
