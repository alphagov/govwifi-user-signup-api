describe WifiUser::Repository::User do
  after do
    DB[:userdetails].truncate
  end

  describe '#generate' do
    ALPHABET_WITHOUT_VOWELS = %w(b c d f g h j k l m n p q r s t v w x y z).freeze

    let(:word_list) { %w[These Are Words] }

    before do
      stub_const("#{described_class}::WORD_LIST", word_list)
    end

    let!(:user) do
      srand(2)
      described_class.new.generate(contact: email)
    end

    let(:random_username) do
      srand(2)
      (0...6).map { ALPHABET_WITHOUT_VOWELS[rand(ALPHABET_WITHOUT_VOWELS.count)] }.join
    end

    context 'new user' do
      let(:email) { 'foo@bar.gov.uk' }
      let(:username_password_from_db) { described_class.select(:username, :password).first.values }
      let(:user_from_db) { described_class.first }
      let(:split_password) { user[:password].split(/(?=[A-Z])/) }

      it 'creates a user and returns it' do
        expect(user[:username]).to eq(random_username)
        expect(user[:password]).not_to be_empty
      end

      it 'creates a random password from the word list' do
        expect(split_password.sort).to eq(word_list.sort)
      end

      it 'stores the user in the database' do
        expect(username_password_from_db).to eq(user)
      end

      it 'stores the email as both the contact and sponsor for the user' do
        expect(user_from_db.contact).to eq(email)
        expect(user_from_db.sponsor).to eq(email)
      end

      context 'avoiding potential offensive usernames' do
        let(:email) { 'foo@bar.gov.uk' }

        it 'does not allow usernames containing any vowels' do
          expect(user[:username]).to eq(random_username)
        end
      end
    end
  end

  context 'generate with a sponsor value specified' do
    let(:user_from_db) { described_class.first }

    it 'stores the sponsor in the sponsor field' do
      described_class.new.generate(contact: 'adrian@example.com', sponsor: 'emile@example.com')

      expect(user_from_db.contact).to eq('adrian@example.com')
      expect(user_from_db.sponsor).to eq('emile@example.com')
    end
  end

  context 'avoiding duplicate usernames' do
    before do
      srand(2)
      described_class.new.generate(contact: 'foo@bar.gov.uk')
    end

    let!(:user) do
      srand(2)
      described_class.new.generate(contact: 'foo1@bar.gov.uk')
    end

    let(:first_user_from_db) { described_class.select(:username, :password).first.values }
    let(:last_user_from_db) { described_class.select(:username, :password).last.values }

    it 'creates a user and returns it' do
      expect(user[:username]).not_to be_empty
      expect(user[:password]).not_to be_empty
    end

    it 'does not duplicate the username' do
      expect(first_user_from_db[:username]).not_to eq(last_user_from_db[:username])
    end
  end

  context 'existing users' do
    before do
      srand(2)
      described_class.new.generate(contact: 'foo@bar.gov.uk')
    end

    let!(:user) do
      described_class.new.generate(contact: 'foo@bar.gov.uk')
    end

    let(:user_from_db) { described_class.select(:username, :password).first.values }

    it 'does not create a new user' do
      expect(described_class.count).to eq(1)
    end

    it 'returns the username and password of the user' do
      expect(user).to eq(user_from_db)
    end
  end
end
