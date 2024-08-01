class WifiUser::UseCase::SmsTemplateFinder
  def execute(sms_content:)
    return "credentials_sms" if sms_content.match?(/^\s*$/) || sms_content.match(/go/i)
    return "help_menu_sms" if sms_content.match?(/help/i)

    device_help_template_name(sms_content) || "recap_sms"
  end

private

  attr_reader :environment

  def device_help_template_name(sms_content)
    device_name_matchers.lazy.map { |matcher, device_name|
      "device_help_#{device_name}_sms" if sms_content.match?(matcher)
    }.find { |result| !result.nil? }
  end

  def device_name_matchers
    {
      /0|other/i => "other",
      /1|android|samsung|galaxy|htc|huawei|sony|motorola|lg|nexus/i => "android",
      /2|ios|ipad|iphone|ipod/i => "iphone",
      /3|mac|OSX|apple/i => "mac",
      /4|win|windows/i => "windows",
      /5|blackberry/i => "blackberry",
      /6|chromebook/i => "chromebook",
    }
  end
end
