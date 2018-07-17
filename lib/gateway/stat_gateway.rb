class StatGateway
  def signups
    {
      today: signups_today.count,
      total: signups_total.count,
      sms_today: sms_signups_today.count,
      sms_total: sms_signups_total.count,
      email_today: email_signups_today.count,
      email_total: email_signups_total.count
    }
  end

private

  def signups_today
    User
      .where(Sequel[:created_at] > Date.today)
      .where(Sequel[:created_at] < Date.today + 1)
  end

  def signups_total
    User.where(Sequel[:created_at] < Date.today + 1)
  end

  def sms_signups_today
    signups_today
      .where(Sequel.like(:contact, '+%'))
      .where(contact: Sequel[:sponsor])
  end

  def sms_signups_total
    signups_total
      .where(Sequel.like(:contact, '+%'))
      .where(contact: Sequel[:sponsor])
  end

  def email_signups_today
    signups_today
      .where(Sequel.like(:contact, '%@%'))
      .where(contact: Sequel[:sponsor])
  end

  def email_signups_total
    signups_total
      .where(Sequel.like(:contact, '%@%'))
      .where(contact: Sequel[:sponsor])
  end
end
