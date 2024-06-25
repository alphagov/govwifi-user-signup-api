require "sequel"

Sequel.migration do
  change do
    Sequel::Model(:userdetails)["UPDATE userdetails SET followup_sent_at = '2000-01-01' where last_login IS NULL"]
  end
end
