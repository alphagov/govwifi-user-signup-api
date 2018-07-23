task :publish_daily_statistics do
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  volumetrics_gateway = PerformancePlatform::Gateway::Volumetrics.new
  volumetrics_presenter =  PerformancePlatform::Presenter::Volumetrics
  
  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: volumetrics_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: volumetrics_presenter)
end

task :publish_weekly_statistics do
  performance_gateway = PerformancePlatform::Gateway::PerformanceReport.new
  completion_rate_gateway = PerformancePlatform::Gateway::CompletionRate.new
  completion_rate_presenter = PerformancePlatform::Presenter::CompletionRate.new

  PerformancePlatform::UseCase::SendPerformanceReport.new(
    stats_gateway: completion_rate_gateway,
    performance_gateway: performance_gateway
  ).execute(presenter: completion_rate_presenter)
end