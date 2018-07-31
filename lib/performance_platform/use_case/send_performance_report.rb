require 'logger'

class PerformancePlatform::UseCase::SendPerformanceReport
  def initialize(stats_gateway:, performance_gateway:)
    @stats_gateway = stats_gateway
    @performance_gateway = performance_gateway
  end

  def execute(presenter:)
    stats = stats_gateway.fetch_stats
    performance_data = presenter.present(stats: stats)
    logger = Logger.new(STDOUT)
    logger.info("Sending performance data: #{performance_data}")

    performance_gateway.send_stats(performance_data)
  end

private

  attr_reader :stats_gateway, :performance_gateway
end
