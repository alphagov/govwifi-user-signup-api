class Common::EmailAddress
  def self.authorised_email_domain?(from_address)
    authorised_email_domains_regex.match?(from_address)
  end

  def self.authorised_email_domains_regex
    Regexp.new(ENV.fetch('AUTHORISED_EMAIL_DOMAINS_REGEX'))
  end
end
