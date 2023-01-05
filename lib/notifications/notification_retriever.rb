module Notifications
  class NotificationRetriever
    def self.execute
      dataset = DB[:notifications]
      client = Notifications::Gateway::Notify.new
      client.to_enum.each do |notification|
        upsert_hash = {
          id: notification.id,
          reference: notification.reference,
          email_address: notification.email_address,
          phone_number: notification.phone_number,
          type: notification.type,
          status: notification.status,
          template_version: notification.template&.[]("version"),
          template_id: notification.template&.[]("id"),
          template_uri: notification.template&.[]("uri"),
          body: notification.body,
          subject: notification.subject,
          created_at: notification.created_at,
          sent_at: notification.sent_at,
          completed_at: notification.completed_at,
        }
        rec = dataset.where(id: notification.id)
        dataset.insert(upsert_hash) unless rec.update(upsert_hash) == 1
      end
    end
  end
end
