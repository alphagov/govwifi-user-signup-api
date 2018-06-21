class User < Sequel::Model(:userdetails)
  User.unrestrict_primary_key
  WORD_LIST = File.readlines(ENV['WORD_LIST_FILE']).map(&:strip)

  def generate(email:)
    username = ('a'..'z').to_a.sample(6).join
    password = WORD_LIST.sample(3).map(&:capitalize).join
    User.create(username: username, password: password)
    { username: username, password: password }
  end
end
