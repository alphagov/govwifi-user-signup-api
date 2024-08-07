FactoryBot.define do
  factory :notification, class: Hash do
    id { SecureRandom.uuid }
    sequence :reference, 1 do |n|
      "reference#{n}"
    end
    sequence :email_address, 1 do |n|
      "someone1.somewhere#{n}.com"
    end
    sequence :phone_number, 1 do |n|
      "12345#{n}"
    end
    type { "email" }
    status { "delivered" }
    transient do
      uuid { SecureRandom.uuid }
    end
    template do
      {
        "version" => "1",
        "id" => uuid.to_s,
        "uri" => "/v2/template/#{uuid}/1",
      }
    end
    sequence :body, 1 do |n|
      "body_#{n}"
    end
    sequence :subject, 1 do |n|
      "subject_#{n}"
    end
    created_at { Time.now - 3600 }
    sent_at { Time.now - 1800 }
    sequence :created_by_name, 1 do |n|
      "name_#{n}"
    end
    completed_at { Time.now }
    initialize_with { attributes }
  end
end
