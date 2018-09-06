class PerformancePlatform::Gateway::CompletionRate
  def initialize(date: Date.today.to_s)
    @date = Date.parse(date)
  end

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

  attr_reader :date

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def sms_registered
    repository.self_sign.with_sms.week_before(date)
  end

  def email_registered
    repository.self_sign.with_email.week_before(date)
  end

  def sponsor_registered
    repository.sponsored.week_before(date)
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
