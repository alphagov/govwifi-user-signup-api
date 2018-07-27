class PerformancePlatform::Presenter::Volumetrics
  def present(stats:)
    @stats = stats
    @timestamp = generate_timestamp

    {
      metric_name: stats[:metric_name],
      payload: [
        as_hash(stats[:yesterday], stats[:cumulative], 'all-sign-ups'),
        as_hash(stats[:sms_yesterday], stats[:sms_cumulative], 'sms-sign-ups'),
        as_hash(stats[:email_yesterday], stats[:email_cumulative], 'email-sign-ups'),
        as_hash(stats[:sponsored_yesterday], stats[:sponsored_cumulative], 'sponsored-sign-ups'),
      ]
    }
  end

private

  def generate_timestamp
    "#{Date.today - 1}T00:00:00+00:00"
  end

  def as_hash(count, cumulative_count, channel)
    {
      _id: encode_id(channel),
      _timestamp: timestamp,
      dataType: stats[:metric_name],
      period: stats[:period],
      channel: channel,
      count: count,
      cumulative_count: cumulative_count
    }
  end

  def encode_id(channel)
    Common::Base64.encode_array(
      [
        timestamp,
        ENV.fetch('PERFORMANCE_DATASET'),
        stats[:period],
        stats[:metric_name],
        channel
      ]
    )
  end

  attr_reader :stats, :timestamp
end
