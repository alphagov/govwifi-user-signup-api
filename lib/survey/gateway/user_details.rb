require "logger"

class Survey::Gateway::UserDetails
  def fetch_active
    limit WifiUser::Repository::User
      .where { created_at > (Date.today - 1).to_time }
      .where { created_at <= Date.today.to_time }
      .where { contact =~ sponsor }
      .exclude(last_login: nil)
      .where(signup_survey_sent_at: nil)
  end

  def fetch_inactive
    limit WifiUser::Repository::User
      .where { created_at >= (Date.today - 14).to_time }
      .where { created_at < (Date.today - 13).to_time }
      .where { contact =~ sponsor }
      .where(last_login: nil)
      .where(signup_survey_sent_at: nil)
  end

  def mark_as_sent(query)
    query.update(signup_survey_sent_at: Time.now)
  end

private

  def limit(query)
    total = query.count

    if total.zero?
      query
    else
      query.limit((total * 0.25).ceil)
    end
  end
end
