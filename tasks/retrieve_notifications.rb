require "logger"

task :retrieve_notifications do
  Notifications::NotificationRetriever.execute
end
