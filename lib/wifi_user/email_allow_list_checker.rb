module WifiUser::EmailAllowListChecker
  def valid_email?(email_address)
    allow_list_regexp = Common::Gateway::S3ObjectFetcher.allow_list_regexp
    regexp = Regexp.new(allow_list_regexp, Regexp::IGNORECASE)
    email_address.match?(regexp)
  end

  def invalid_email?(email_address)
    !valid_email?(email_address)
  end
end
