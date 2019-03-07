require 'notifications/client'

class WifiUser::Gateway::GovNotifySMS
  def initialize(api_key, template_id)
    @client = Notifications::Client.new(api_key)
    @template_id = template_id
  end

  def execute(phone_number, template_parameters: {})
    client.send_sms(
      phone_number: phone_number,
      template_id: template_id,
      personalisation: template_parameters
    )
    WifiUser::Domain::SMSResponse.new(success: true)
  end

  private
  attr_accessor :client, :template_id
end
