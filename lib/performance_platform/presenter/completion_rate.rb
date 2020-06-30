class PerformancePlatform::Presenter::CompletionRate
  def initialize(date: Date.today.to_s)
    @date = Date.parse(date)
  end

  def present(stats:)
    @stats = stats
    @timestamp = generate_timestamp

    {
      metric_name: stats[:metric_name],
      payload: [
        as_hash(stats[:sms_registered], "sms", "start"),
        as_hash(stats[:sms_logged_in], "sms", "complete"),
        as_hash(stats[:email_registered], "email", "start"),
        as_hash(stats[:email_logged_in], "email", "complete"),
        as_hash(stats[:sponsor_registered], "sponsor", "start"),
        as_hash(stats[:sponsor_logged_in], "sponsor", "complete")
      ]
    }
  end

private

  attr_reader :date

  def generate_timestamp
    "#{date}T00:00:00+00:00"
  end

  def as_hash(count, channel, stage)
    {
      _id: encode_id(stage, channel),
      _timestamp: timestamp,
      dataType: stats[:metric_name],
      period: stats[:period],
      channel: channel,
      stage: stage,
      count: count,
    }
  end

  def encode_id(stage, channel)
    Common::Base64.encode_array(
      [
        timestamp,
        ENV.fetch("PERFORMANCE_DATASET"),
        stats[:period],
        stats[:metric_name],
        stage,
        channel
      ]
    )
  end

  attr_reader :stats, :timestamp
end
