task :publish_daily_statistics do
  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: PerformancePlatform::Gateway::Statistics.new,
    performance_gateway: PerformancePlatform::Gateway::PerformanceReport.new
  ).execute
end
