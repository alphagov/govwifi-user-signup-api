class WifiUser::User < Sequel::Model(:userdetails)
  include WifiUser::EmailAllowListChecker
  unrestrict_primary_key

  USERNAME_LENGTH = 6
  WORD_LIST = File.readlines(ENV["WORD_LIST_FILE"]).map(&:strip)
  CHARACTER_LIST = %w[b c d f g h j k m n p q r s t v w x y z].freeze

  def before_create
    super
    self.username = random_username
    self.password = password_from_word_list
    self.sponsor ||= contact
  end

  def mobile?
    contact&.start_with? "+"
  end

private

  def random_username
    username = generate_username

    username = generate_username while self.class.find(username:)

    username
  end

  def generate_username
    (0...USERNAME_LENGTH).map { CHARACTER_LIST[rand(CHARACTER_LIST.count)] }.join
  end

  def password_from_word_list
    WORD_LIST.sample(3).map(&:capitalize).join
  end
end
