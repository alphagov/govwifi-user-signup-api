FactoryBot.define do
  factory :request_body, class: Hash do
    skip_create
    Type { type }
    Message do
      {
        mail: {
          messageId:,
          commonHeaders: {
            from: [from],
            to: [to],
          },
        },
        receipt: {
          action: {
            objectKey:,
            bucketName:,
          },
        },
      }.to_json
    end
    initialize_with { attributes }
    transient do
      type { "Notification" }
      messageId { "123" }
      from { "test@gov.uk" }
      to { "signup@wifi.service.gov.uk" }
      objectKey { "my_object_key" }
      bucketName { "my_bucket_name" }
    end
  end
end
