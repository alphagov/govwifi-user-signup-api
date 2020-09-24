module Metrics
  class Volumetrics
    VALID_PERIODS = %w[week day month].freeze

    def initialize(attrs)
      raise ArgumentError unless VALID_PERIODS.include? attrs[:period]

      @period = attrs[:period]
      @date = attrs[:date]
    end

    def execute
      S3Publisher.publish key, stats
    end

    def key
      "volumetrics/volumetrics-#{@period}-#{@date}"
    end

  private

    def stats
      gateway = PerformancePlatform::Gateway::Volumetrics.new(
        period: @period,
        date: @date,
      )
      gateway.fetch_stats
    end
  end
end
