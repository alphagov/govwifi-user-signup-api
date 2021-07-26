class WifiUser::UseCase::ContactSanitiser
  NO_MATCH = [].freeze

  def execute(contact)
    first_match(
      email_match(contact) ||
      internationalize(phone_match(contact.delete(" "))) ||
      NO_MATCH,
    )
  end

private

  def email_match(contact)
    contact.match(/[A-Za-z0-9_+.'\-&]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+/)
  end

  def phone_match(contact)
    contact.match(/\A\+?\d{1,15}\Z/)
  end

  def internationalize(match)
    return [internationalise_phone_number(first_match(match))] if match
  end

  def first_match(match)
    match[0]
  end

  def internationalise_phone_number(phone_number)
    phone_number = "44" + phone_number[1..-1] if phone_number[0..1] == "07"
    phone_number = "+" + phone_number unless phone_number[0] == "+"
    phone_number
  end
end
