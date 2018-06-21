class User < Sequel::Model(:userdetails)
  User.unrestrict_primary_key
  WORD_LIST = File.readlines(ENV['WORD_LIST_FILE']).map(&:strip)

  def generate(email:)
    user = User.create(username: random_username, password: password_from_word_list)
    { username: user.username, password: user.password }
  end

private

  def random_username
    username = generate_username

    while User.find(username: username)
      username = generate_username
    end

    username
  end

  def generate_username
    ('a'..'z').to_a.sample(6).join
  end

  def password_from_word_list
    WORD_LIST.sample(3).map(&:capitalize).join
  end
end
