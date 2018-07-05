class PhoneNumber
  def self.internationalise_phone_number(phone_number)
    phone_number = '44' + phone_number[1..-1] if phone_number[0..1] == '07'
    phone_number = '+' + phone_number unless phone_number[0] == '+'
    phone_number
  end
end
