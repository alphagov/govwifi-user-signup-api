class PerformancePlatform::Gateway::CompletionRate
  def fetch_stats
    {
      period: 'week',
      metric_name: 'completion-rate',
      sms_registered: sms_registered.count,
      sms_logged_in: sms_logged_in.count,
      email_registered: email_registered.count,
      email_logged_in: email_logged_in.count,
      sponsor_registered: sponsor_registered.count,
      sponsor_logged_in: sponsor_logged_in.count,
    }
  end

private

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def sms_registered
    repository.with_sms.last_week
  end

  def email_registered
    repository.with_email.last_week
  end

  def sponsor_registered
    repository.sponsored.last_week
  end

  def sms_logged_in
    sms_registered.with_successful_login
  end

  def email_logged_in
    email_registered.with_successful_login
  end

  def sponsor_logged_in
    sponsor_registered.with_successful_login
  end
end
