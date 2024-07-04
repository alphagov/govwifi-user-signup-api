Sequel.migration do
  change do
    alter_table :userdetails do
      add_column :followup_sent_at, DateTime
    end
  end
end
