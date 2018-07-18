class SendPerformanceStats
  def initialize(stats_gateway:, performance_gateway:)
    @stats_gateway = stats_gateway
    @performance_gateway = performance_gateway
  end

  def execute
    signups = stats_gateway.signups
    performance_data = PerformancePlatformPresenter.new(stats: signups)

    performance_gateway.send_stats(performance_data.present)
  end

private

  attr_reader :stats_gateway, :performance_gateway
end
