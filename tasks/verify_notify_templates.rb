desc "Verify if the required templates are present in Notify. Use the notify key as an argument"

task :verify_notify_templates do
  require "notifications/client"
  require "./lib/services"
  require "./lib/notifications/notify_templates"

  Notifications::NotifyTemplates.verify_templates
rescue StandardError => e
  abort e.message
end
