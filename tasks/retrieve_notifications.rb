require "logger"

task :retrieve_notifications do
  require "./lib/loader"
  Notifications::NotificationRetriever.execute
end
