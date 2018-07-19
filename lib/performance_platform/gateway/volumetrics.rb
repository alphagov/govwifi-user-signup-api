class PerformancePlatform::Gateway::Volumetrics
  def fetch_stats
    {
      period: 'day',
      metric_name: 'volumetrics',
      today: signups_today.count,
      cumulative: signups_cumulative.count,
      sms_today: sms_signups_today.count,
      sms_cumulative: sms_signups_cumulative.count,
      email_today: email_signups_today.count,
      email_cumulative: email_signups_cumulative.count,
      sponsored_today: sponsored_signups_today.count,
      sponsored_cumulative: sponsored_signups_cumulative.count
    }
  end

private

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def signups_today
    repository.all.today
  end

  def signups_cumulative
    repository.all
  end

  def sms_signups_today
    signups_today.self_sign.with_sms
  end

  def sms_signups_cumulative
    signups_cumulative.self_sign.with_sms
  end

  def email_signups_today
    signups_today.self_sign.with_email
  end

  def email_signups_cumulative
    signups_cumulative.self_sign.with_email
  end

  def sponsored_signups_cumulative
    signups_cumulative.sponsored
  end

  def sponsored_signups_today
    signups_today.sponsored.today
  end
end
