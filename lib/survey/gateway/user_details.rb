require "logger"

class Survey::Gateway::UserDetails
  def fetch
    all = WifiUser::Repository::User
            .where { created_at > Time.now - 1 * 3600 * 24 }
            .where { contact =~ sponsor }
            .exclude(last_login: nil)
            .where(signup_survey_sent_at: nil)

    total = all.count

    if total.zero?
      all
    else
      all.limit((total * 0.25).ceil)
    end
  end

  def mark_as_sent(query)
    query.update(signup_survey_sent_at: Time.now)
  end
end
