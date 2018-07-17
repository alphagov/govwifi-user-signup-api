task :publish_daily_statistics do
  SendPerformanceStats.new(
    stats_gateway: StatGateway.new,
    performance_gateway: PerformancePlatformGateway.new
  ).execute
end
