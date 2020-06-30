class PerformancePlatform::Gateway::Volumetrics
  attr_reader :period

  def initialize(date: Date.today.to_s, period: "day")
    @date = Date.parse(date)
    @period = period
  end

  def fetch_stats
    {
      period: period,
      metric_name: "volumetrics",
      period_before: signups_period_before.count,
      cumulative: signups_cumulative.count,
      sms_period_before: sms_signups_period_before.count,
      sms_cumulative: sms_signups_cumulative.count,
      email_period_before: email_signups_period_before.count,
      email_cumulative: email_signups_cumulative.count,
      sponsored_period_before: sponsored_signups_period_before.count,
      sponsored_cumulative: sponsored_signups_cumulative.count,
    }
  end

private

  attr_reader :date

  def repository
    PerformancePlatform::Repository::SignUp
  end

  def signups_period_before
    repository.send("#{period}_before", date)
  end

  def signups_cumulative
    repository.all(date)
  end

  def sms_signups_period_before
    signups_period_before.self_sign.with_sms
  end

  def sms_signups_cumulative
    signups_cumulative.self_sign.with_sms
  end

  def email_signups_period_before
    signups_period_before.self_sign.with_email
  end

  def email_signups_cumulative
    signups_cumulative.self_sign.with_email
  end

  def sponsored_signups_cumulative
    signups_cumulative.sponsored
  end

  def sponsored_signups_period_before
    signups_period_before.sponsored
  end
end
