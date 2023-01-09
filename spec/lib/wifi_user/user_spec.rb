describe WifiUser::User do
  describe "#create" do
    let(:word_list) { %w[These Are Words] }
    let(:character_list) { %w[b c] }
    let(:username_length) { 3 }

    before do
      stub_const("#{described_class}::WORD_LIST", word_list)
      stub_const("#{described_class}::CHARACTER_LIST", character_list)
      stub_const("#{described_class}::USERNAME_LENGTH", username_length)
    end

    context "new user" do
      let(:email) { "foo@bar.gov.uk" }

      it "creates a user and sets the username and password" do
        user = WifiUser::User.create(contact: email)
        expect(user[:password]).to_not be_nil
        expect(user[:username]).to_not be_nil
      end

      it "creates a username of length USERNAME_LENGTH" do
        user = WifiUser::User.create(contact: email)
        expect(user.username.length).to eq(username_length)
      end

      it "creates a username containing only letters from CHARACTER_LIST" do
        user = WifiUser::User.create(contact: email)
        expect(user.username.each_char.all? { |char| character_list.include?(char) }).to be true
      end

      it "creates a random password from the word list" do
        user = WifiUser::User.create(contact: email)
        expect(user.password.chars.sort).to eq(word_list.join.chars.sort)
      end

      it "creates a valid user" do
        user = WifiUser::User.create(contact: email)
        expect(user).to be_valid
      end

      it "stores the email as both the contact and sponsor for the user if only the contact is given" do
        user = WifiUser::User.create(contact: email)
        expect(user.contact).to eq(email)
        expect(user.contact).to eq(user.sponsor)
      end

      it "stores the email and sponsor for the user if both are given" do
        user = WifiUser::User.create(contact: email, sponsor: "sponsor@gov.uk")
        expect(user.contact).to eq(email)
        expect(user.sponsor).to eq("sponsor@gov.uk")
      end

      it "does not create duplicate usernames" do
        number_of_possible_combinations = character_list.length**username_length
        users = (1..number_of_possible_combinations).map { |number| WifiUser::User.create(contact: "user_#{number}@gov.uk") }
        expect(users.map(&:username).uniq.length).to eq(number_of_possible_combinations)
      end
    end
  end
end
