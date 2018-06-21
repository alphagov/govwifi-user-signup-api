RSpec.describe User do
  after do
    DB[:userdetails].truncate
  end

  describe '#generate' do
    context 'new user' do
      before do
        stub_const('User::WORD_LIST', word_list)
      end

      let(:random_username) do
        srand(2)
        ('a'..'z').to_a.sample(6).join
      end

      let(:word_list) { %w[These Are Words] }

      let!(:user) do
        srand(2)
        User.new.generate(email: 'foo@bar.gov.uk')
      end

      let(:user_from_db) { User.select(:username, :password).first.values }
      let(:split_password) { user[:password].split(/(?=[A-Z])/) }

      it 'creates a user and returns it' do
        expect(user[:username]).to eq(random_username)
        expect(user[:password]).not_to be_empty
      end

      it 'creates a random password from the word list' do
        expect(split_password.sort).to eq(word_list.sort)
      end

      it 'stores the user in the database' do
        expect(user_from_db).to eq(user)
      end
    end
  end

  context 'avoiding duplicate usernames' do
    before do
      srand(2)
      ('a'..'z').to_a.sample(6).join
      srand(2)
      User.new.generate(email: 'foo@bar.gov.uk')
    end

    let!(:user) do
      srand(2)
      User.new.generate(email: 'foo1@bar.gov.uk')
    end

    let(:first_user_from_db) { User.select(:username, :password).first.values }
    let(:last_user_from_db) { User.select(:username, :password).last.values }

    it 'creates a user and returns it' do
      expect(user[:username]).not_to be_empty
      expect(user[:password]).not_to be_empty
    end

    it 'does not duplicate the username' do
      expect(first_user_from_db[:username]).not_to eq(last_user_from_db[:username])
    end
  end
end

# CREATE TABLE `userdetails` (
#   `username` varchar(10) NOT NULL DEFAULT '',
#   `contact` varchar(100) DEFAULT NULL,
#   `sponsor` varchar(100) DEFAULT NULL,
#   `password` varchar(64) DEFAULT NULL,
#   `email` varchar(100) DEFAULT NULL,
#   `mobile` varchar(20) DEFAULT NULL,
#   `notifications_opt_out` tinyint(1) NOT NULL DEFAULT '0',
#   `survey_opt_out` tinyint(1) NOT NULL DEFAULT '0',
#   `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
#   `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#   `last_login` datetime DEFAULT NULL,
#   PRIMARY KEY (`username`),
#   KEY `userdetails_created_at` (`created_at`),
#   KEY `userdetails_contact` (`contact`),
#   KEY `userdetails_last_login` (`last_login`)
# ) 
