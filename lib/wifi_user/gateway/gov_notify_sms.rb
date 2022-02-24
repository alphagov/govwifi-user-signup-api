require "notifications/client"

class WifiUser::Gateway::GovNotifySMS
  def initialize(api_key)
    @client = Notifications::Client.new(api_key)
  end

  def execute(phone_number:, template_id:, template_parameters: {})
    begin
      client.send_sms(
        phone_number:,
        template_id:,
        personalisation: template_parameters,
      )
      success = true
    rescue Notifications::Client::RequestError => e
      raise unless is_validation_error?(e)

      success = false
    end
    WifiUser::Domain::SMSResponse.new(success:)
  end

private

  attr_accessor :client

  def is_validation_error?(error)
    error.message.include?("ValidationError")
  end
end
