require "nokogiri"

class WifiUser::UseCase::EmailSponseesExtractor
  def initialize(sns_message:)
    @sns_message = sns_message
  end

  def execute
    email_contents = Common::Gateway::S3ObjectFetcher.new(bucket: @sns_message.s3_bucket_name,
                                                          key: @sns_message.s3_object_key).fetch
    lines_in_email = extract_lines_from email_contents
    contacts = extract_contact_details_from lines_in_email
    remove_sponsor_from contacts
  rescue Mail::Field::ParseError => e
    raise "unable to parse email address in #{@sns_message.parsed_message}: #{e}"
  end

private

  def extract_contact_details_from(lines)
    contacts = lines.map do |line|
      WifiUser::EmailAddress.extract_from(line) || WifiUser::PhoneNumber.extract_from(line)
    end
    contacts.compact
  end

  def remove_sponsor_from(contacts)
    contacts.reject { |contact| contact == @sns_message.from_address }
  end

  def extract_lines_from(email_contents)
    mail = Mail.read_from_string(email_contents)
    if !mail.multipart?
      lines_from_plain_text(mail.body)
    elsif mail.text_part
      lines_from_plain_text(mail.text_part)
    else
      lines_from_html(mail.html_part)
    end
  end

  def lines_from_plain_text(text_part)
    text_part.decoded.lines "\n"
  end

  def lines_from_html(html_part)
    Nokogiri::HTML(html_part.decoded).xpath("//text()[not(ancestor::style) and not(ancestor::img)]").map do |node|
      node.xpath("normalize-space()")
    end
  end
end
