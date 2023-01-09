require "logger"

class Survey::Gateway::UserDetails
  def fetch_active
    WifiUser::User
      .where { created_at > (Date.today - 1).to_time }
      .where { created_at <= Date.today.to_time }
      .where { contact =~ sponsor }
      .exclude(last_login: nil)
      .where(signup_survey_sent_at: nil)
  end

  def mark_as_sent(query)
    query.update(signup_survey_sent_at: Time.now)
  end
end
