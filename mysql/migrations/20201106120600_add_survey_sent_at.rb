Sequel.migration do
  change do
    alter_table :userdetails do
      add_column :signup_survey_sent_at, DateTime
    end
  end
end
