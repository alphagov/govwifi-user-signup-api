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

  def repository
    SignUp
  end

  def signups_today
    repository.all.today
  end

  def signups_total
    repository.all
  end

  def sms_signups_today
    signups_today.self_sign.with_sms
  end

  def sms_signups_total
    signups_total.self_sign.with_sms
  end

  def email_signups_today
    signups_today.self_sign.with_email
  end

  def email_signups_total
    signups_total.self_sign.with_email
  end
end
