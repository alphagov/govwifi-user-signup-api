class WifiUser::EmailAddress
  EMAIL_ADDRESS_REGEX = /(?<email_address>[A-Za-z0-9_+.'\-&]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+)/

  def self.extract_from(text)
    match_data = EMAIL_ADDRESS_REGEX.match(text)
    match_data && match_data[:email_address]
  end
end
