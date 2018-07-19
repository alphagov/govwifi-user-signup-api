class WifiUser::UseCase::SmsTemplateFinder
  def initialize(environment:)
    @environment = environment
  end

  def execute(message_content:)
    device_name_matchers.each do |matcher, device_name|
      return device_instruction_config.fetch(device_name) if message_content.match?(matcher)
    end

    template_name = 'generic_help'
    template_name = 'credentials' if message_content.match?(/^\s*$/) || message_content.match(/go/i)
    template_name = 'help_menu' if message_content.match?(/help/i)

    config[template_name]
  end

private

  attr_reader :environment

  def device_instruction_config
    config.fetch('device_help')
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

  def config
    YAML.load_file("config/#{environment}.yml")['notify_sms_template_ids']
  end
end
