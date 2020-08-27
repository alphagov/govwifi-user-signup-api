Sequel.migration do
  change do
    create_table(:notifications) do
      String :id, size: 35, null: false, primary_key: true
      String :reference, size: 200
      String :email_address, size: 100
      String :phone_number, size: 100
      String :type, size: 6
      String :status, size: 15
      String :template_version, size: 10
      String :template_id, size: 36
      String :template_uri, size: 100
      String :body, size: 1024
      String :subject, size: 100
      Timestamp :created_at, default: Sequel.lit("now()"), index: true
      DateTime :sent_at
      DateTime :completed_at
    end
  end
end
