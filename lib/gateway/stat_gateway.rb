class StatGateway
  def signups
    {
      today: signups_today,
      total: signups_total
    }
  end

private

  def signups_today
    User
      .where(Sequel[:created_at] > Date.today)
      .where(Sequel[:created_at] < Date.today + 1)
      .count
  end

  def signups_total
    User
      .where(Sequel[:created_at] < Date.today + 1)
      .count
  end
end
