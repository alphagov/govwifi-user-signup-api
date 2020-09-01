Sequel.migration do
  change do
    create_table?(:userdetails) do
      String :username, size: 10, default: "", null: false, primary_key: true
      String :contact, size: 100, index: true
      String :sponsor, size: 100
      String :password, size: 64
      String :email, size: 100
      String :mobile, size: 20
      TrueClass :notifications_opt_out, default: 0, null: false
      TrueClass :survey_opt_out, default: 0, null: false
      Timestamp :created_at, default: Sequel.lit("now()"), index: true
      Timestamp :updated_at, default: Sequel.lit("CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
      DateTime :last_login, index: true
    end
  end
end
