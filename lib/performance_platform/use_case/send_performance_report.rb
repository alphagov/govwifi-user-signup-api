class PerformancePlatform::UseCase::SendPerformanceReport
  def initialize(stats_gateway:, performance_gateway:)
    @stats_gateway = stats_gateway
    @performance_gateway = performance_gateway
  end

  def execute
    stats = stats_gateway.fetch_stats
    performance_data = PerformancePlatform::Presenter::Report
      .new(stats: stats)
      .present

    performance_gateway.send_stats(performance_data)
  end

private

  attr_reader :stats_gateway, :performance_gateway
end
