require "logger"

task :inactive_user_followup do
  require "./lib/loader"
  Followups::FollowupSender.send_messages
end
