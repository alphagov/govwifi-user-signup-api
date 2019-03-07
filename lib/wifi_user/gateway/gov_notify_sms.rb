require 'notifications/client'

class WifiUser::Gateway::GovNotifySMS
  def initialize(api_key)
    @client = Notifications::Client.new(api_key)
  end

  def execute(phone_number, template_id, template_parameters: {})
    client.send_sms(
      phone_number: phone_number,
      template_id: template_id,
      personalisation: template_parameters
    )
    WifiUser::Domain::SMSResponse.new(success: true)
  end

private

  attr_accessor :client
end
