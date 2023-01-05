require "notifications/client"

class WifiUser::Gateway::GovNotifyEmail
  def initialize
    @client = Services.notify_client
  end

  def execute(email_address:, template_id:, template_parameters: {}, reply_to_id: nil)
    begin
      client.send_email(
        email_address:,
        template_id:,
        personalisation: template_parameters,
        email_reply_to_id: reply_to_id,
      )
      success = true
    rescue Notifications::Client::RequestError => e
      raise unless is_validation_error?(e)

      success = false
    end
    WifiUser::Domain::EmailResponse.new(success:)
  end

private

  attr_accessor :client

  def is_validation_error?(error)
    error.message.include?("ValidationError")
  end
end
