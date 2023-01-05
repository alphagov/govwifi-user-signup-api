require "notifications/client"

module Notifications
  module Gateway
    class Notify
      def initialize
        @client = Services.notify_client
      end

      def to_enum
        args = {}
        Enumerator.new do |yielder|
          until (notifications = @client.get_notifications(args).collection).empty?
            notifications.each { |notification| yielder << notification }
            args.merge!(older_than: notifications.last.id)
          end
        end
      end
    end
  end
end
