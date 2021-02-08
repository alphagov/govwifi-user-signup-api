Sequel.migration do
  change do
    create_table?(:smslog) do
      primary_key :id
      String :number, size: 100, default: "", null: false
      String :message, size: 918, default: "", null: false
      Timestamp :created_at, default: Sequel.lit("now()"), index: true
      index [:created_at, :number]
    end
  end
end
