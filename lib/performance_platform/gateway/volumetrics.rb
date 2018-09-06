class PerformancePlatform::Gateway::Volumetrics
  def initialize(date: Date.today.to_s)
    @date = Date.parse(date)
  end

  def fetch_stats
    {
      period: 'day',
      metric_name: 'volumetrics',
      day_before: signups_day_before.count,
      cumulative: signups_cumulative.count,
      sms_day_before: sms_signups_day_before.count,
      sms_cumulative: sms_signups_cumulative.count,
      email_day_before: email_signups_day_before.count,
      email_cumulative: email_signups_cumulative.count,
      sponsored_day_before: sponsored_signups_day_before.count,
      sponsored_cumulative: sponsored_signups_cumulative.count
    }
  end

private

  attr_reader :date

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def signups_day_before
    repository.day_before(date)
  end

  def signups_cumulative
    repository.all(date)
  end

  def sms_signups_day_before
    signups_day_before.self_sign.with_sms
  end

  def sms_signups_cumulative
    signups_cumulative.self_sign.with_sms
  end

  def email_signups_day_before
    signups_day_before.self_sign.with_email
  end

  def email_signups_cumulative
    signups_cumulative.self_sign.with_email
  end

  def sponsored_signups_cumulative
    signups_cumulative.sponsored
  end

  def sponsored_signups_day_before
    signups_day_before.sponsored
  end
end
