require 'logger'
logger = Logger.new(STDOUT)

task :publish_daily_statistics, :date do |_, args|
  args.with_defaults(date: Date.today.to_s)
  logger.info("publishing daily statistics with #{args}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  volumetrics_gateway = PerformancePlatform::Gateway::Volumetrics.new(date: args[:date])
  volumetrics_presenter = PerformancePlatform::Presenter::Volumetrics.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: volumetrics_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: volumetrics_presenter)
end

task :publish_weekly_statistics, :date do |_, args|
  args.with_defaults(date: Date.today.to_s)
  logger.info("publishing weekly statistics #{args}")
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  completion_rate_gateway = PerformancePlatform::Gateway::CompletionRate.new(date: args[:date])
  completion_rate_presenter = PerformancePlatform::Presenter::CompletionRate.new(date: args[:date])

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: completion_rate_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: completion_rate_presenter)
end
