desc "Verify if the required templates are present in Notify. Use the notify key as an argument"

task :verify_notify_templates, [:key] do |_, args|
  require "./lib/loader"

  client = Notifications::Client.new(args.key)
  names = client.get_all_templates.collection.map(&:name)
  differences = Notifications::NotifyTemplates::TEMPLATES - names
  abort "Some templates have not been defined in Notify: #{differences.join(', ')}" unless differences.empty?
end
