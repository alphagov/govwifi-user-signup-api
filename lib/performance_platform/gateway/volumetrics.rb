class PerformancePlatform::Gateway::Volumetrics
  def fetch_stats
    {
      period: 'day',
      metric_name: 'volumetrics',
      yesterday: signups_yesterday.count,
      cumulative: signups_cumulative.count,
      sms_yesterday: sms_signups_yesterday.count,
      sms_cumulative: sms_signups_cumulative.count,
      email_yesterday: email_signups_yesterday.count,
      email_cumulative: email_signups_cumulative.count,
      sponsored_yesterday: sponsored_signups_yesterday.count,
      sponsored_cumulative: sponsored_signups_cumulative.count
    }
  end

private

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def signups_yesterday
    repository.yesterday
  end

  def signups_cumulative
    repository.all
  end

  def sms_signups_yesterday
    signups_yesterday.self_sign.with_sms
  end

  def sms_signups_cumulative
    signups_cumulative.self_sign.with_sms
  end

  def email_signups_yesterday
    signups_yesterday.self_sign.with_email
  end

  def email_signups_cumulative
    signups_cumulative.self_sign.with_email
  end

  def sponsored_signups_cumulative
    signups_cumulative.sponsored
  end

  def sponsored_signups_yesterday
    signups_yesterday.sponsored
  end
end
