class SmsTemplateFinder
  def execute(message_content:, env:)
    device_name_matchers.each do |matcher, device_name|
      return device_instruction_config(env).fetch(device_name) if message_content.match?(matcher)
    end

    template_name = 'generic_help'
    template_name = 'credentials' if message_content.match?(/^\s*$/) || message_content.match(/go/i)
    template_name = 'help_menu' if message_content.match?(/help/i)

    config(env)[template_name]
  end

private

  def device_instruction_config(env)
    config(env).fetch('device_help')
  end

  def device_name_matchers
    {
      /1|android|samsung|galaxy|htc|huawei|sony|motorola|lg|nexus/i => 'android',
      /2|ios|ipad|iphone|ipod/i => 'iphone',
      /3|mac|OSX|apple/i => 'mac',
      /4|win|windows/i => 'windows',
      /5|blackberry/i => 'blackberry',
    }
  end

  def config(env)
    YAML.load_file("config/#{env}.yml")['notify_sms_template_ids']
  end
end
