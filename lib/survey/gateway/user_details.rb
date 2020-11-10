require "logger"

class Survey::Gateway::UserDetails
  def fetch
    WifiUser::Repository::User
      .where { created_at > Time.now - 1 }
      .where { contact =~ sponsor }
      .exclude(last_login: nil)
      .where(signup_survey_sent_at: nil)
  end
end
