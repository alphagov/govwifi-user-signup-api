describe SmokeTests::Gateway::UserDetails do
  let(:user_details) { DB[:userdetails] }

  before { user_details.delete }

  context "Deleting smoke test users" do
    context "Given no test users" do
      before do
        user_details.insert(username: "foo", contact: "foo@example.com", created_at: Date.today - 1)
        user_details.insert(username: "bar", contact: "bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
      end

      it "does not delete any users" do
        expect { subject.delete_users }.not_to(change { user_details.count })
      end
    end

    context "Given one test user" do
      before do
        user_details.insert(username: "foo", contact: "foo@example.com", created_at: Date.today - 1)
        user_details.insert(username: "bar", contact: "bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        user_details.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
      end

      it "deletes only the old test user record" do
        subject.delete_users
        expect(user_details.all.map { |s| s.fetch(:username) }).not_to include("baz")
      end
    end

    context "Given multiple test users" do
      before do
        user_details.insert(username: "foo", contact: "govwifi-tests+foo@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        user_details.insert(username: "bar", contact: "govwifi-tests+bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        user_details.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
      end

      it "deletes all the test users" do
        subject.delete_users
        expect(user_details.all).to be_empty
      end
    end

    context "Given a recently created test user" do
      before do
        user_details.insert(username: "foo", contact: "govwifi-tests+foo@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        user_details.insert(username: "bar", contact: "govwifi-tests+bar@digital.cabinet-office.gov.uk", created_at: Date.today - 1)
        user_details.insert(username: "baz", contact: "govwifi-tests+baz@digital.cabinet-office.gov.uk")
      end

      it "does not delete the recent test user" do
        subject.delete_users
        expect(user_details.all.map { |s| s.fetch(:username) }).to include("baz")
      end
    end
  end
end
