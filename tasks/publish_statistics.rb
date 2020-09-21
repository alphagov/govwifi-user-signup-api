require "logger"
logger = Logger.new(STDOUT)

PERIODS = {
  daily: "day",
  weekly: "week",
  monthly: "month",
}.freeze

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
