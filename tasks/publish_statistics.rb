require "logger"
logger = Logger.new(STDOUT)

PERIODS = {
  daily: "day",
  weekly: "week",
  monthly: "month",
}.freeze

PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_statistics".to_sym

  task name, [:date] do |_, args|
    require "./lib/loader"

    args.with_defaults(date: Date.today.to_s)
    logger.info("Publishing #{adverbial} statistics with #{args[:date]}")
    performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new

    if period != "week"
      volumetrics_gateway = PerformancePlatform::Gateway::Volumetrics.new(date: args[:date], period: period)
      volumetrics_presenter = PerformancePlatform::Presenter::Volumetrics.new(date: args[:date])

      PerformancePlatform::UseCase::SendPerformanceReport.new(
        stats_gateway: volumetrics_gateway,
        performance_gateway: performance_gateway,
      ).execute(presenter: volumetrics_presenter)
    end

    completion_rate_gateway = PerformancePlatform::Gateway::CompletionRate.new(date: args[:date], period: period)
    completion_rate_presenter = PerformancePlatform::Presenter::CompletionRate.new(date: args[:date])

    PerformancePlatform::UseCase::SendPerformanceReport.new(
      stats_gateway: completion_rate_gateway,
      performance_gateway: performance_gateway,
    ).execute(presenter: completion_rate_presenter)
  end
end

PERIODS.each do |adverbial, period|
  name = "publish_#{adverbial}_metrics".to_sym

  task name, [:date] do |_, args|
    require "./lib/loader"

    args.with_defaults(date: Date.today.to_s)

    logger.info("Creating #{adverbial} metrics for S3 with #{args[:date]}")

    metrics_list = [Metrics::Volumetrics.new(period: period, date: args[:date]),
                    Metrics::CompletionRate.new(period: period, date: args[:date])]

    metrics_list.each do |metrics|
      logger.info("[#{metrics.key}] Fetching and uploading metrics...")

      metrics.execute

      logger.info("[#{metrics.key}] Done.")
    end
  end
end
