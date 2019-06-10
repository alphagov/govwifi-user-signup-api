class WifiUser::Repository::User < Sequel::Model(:userdetails)
  self.unrestrict_primary_key

  WORD_LIST = File.readlines(ENV['WORD_LIST_FILE']).map(&:strip)

  def generate(contact:, sponsor: contact)
    existing_user = self.class.find(contact: contact)
    return login_details(existing_user) if existing_user

    user = create_user(contact, sponsor)
    login_details(user)
  end

private

  CHARACTER_LIST = %w(b c d f g h j k m n p q r s t v w x y z).freeze

  def random_username
    username = generate_username

    while self.class.find(username: username)
      username = generate_username
    end

    username
  end

  def generate_username
    (0...6).map { CHARACTER_LIST[rand(CHARACTER_LIST.count)] }.join
  end

  def password_from_word_list
    WORD_LIST.sample(3).map(&:capitalize).join
  end

  def create_user(contact, sponsor)
    self.class.create(
      username: random_username,
      password: password_from_word_list,
      contact: contact,
      sponsor: sponsor
    )
  end

  def login_details(user)
    { username: user.username, password: user.password }
  end
end
