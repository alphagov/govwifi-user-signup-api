class User < Sequel::Model(:userdetails)
  User.unrestrict_primary_key
  WORD_LIST = File.readlines(ENV['WORD_LIST_FILE']).map(&:strip)

  def generate(email:)
    existing_user = User.find(email: email)
    return login_details(existing_user) if existing_user

    user = create_user(email)
    login_details(user)
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

  def create_user(email)
    User.create(
      username: random_username,
      password: password_from_word_list,
      email: email,
      sponsor: email
    )
  end

  def login_details(user)
    { username: user.username, password: user.password }
  end
end
