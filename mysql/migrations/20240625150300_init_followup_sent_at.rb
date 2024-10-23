require "sequel"

Sequel.migration do
  change do
    from(:userdetails).update(followup_sent_at: "2000-01-01")
  end
end
