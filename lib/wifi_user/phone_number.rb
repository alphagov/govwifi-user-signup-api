class WifiUser::PhoneNumber
  require 'phonelib'

  PHONE_NUMBER_REGEX = /\A(?<phone_number>\+?\d{6,15})\Z/

  def self.internationalise(phone_number)
    phone_number = "44#{phone_number[1..]}" if phone_number[0..1] == "07"
    phone_number = "+#{phone_number}" unless phone_number[0] == "+"
    parsed_number = Phonelib.parse(phone_number)
    if parsed_number.valid?
      parsed_number.e164
    else
      raise 'InvalidPhoneError: Not a valid country prefix'
    end
  end

  def self.extract_from(text)
    text_without_spaces = text.gsub(/\s+/, "")
    match_data = PHONE_NUMBER_REGEX.match(text_without_spaces)
    match_data && internationalise(match_data[:phone_number])
  end
end
