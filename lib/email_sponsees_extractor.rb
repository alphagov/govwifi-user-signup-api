require 'nokogiri'

class EmailSponseesExtractor
  def execute(email)
    mail = Mail.read_from_string(email)

    contacts_from_mail(mail).map(&:strip).reject(&:empty?)
  end

private

  def contacts_from_mail(mail)
    if !mail.multipart?
      lines_from_plain_text(mail.body)
    elsif mail.text_part
      lines_from_plain_text(mail.text_part)
    else
      lines_from_html(mail)
    end
  end

  def lines_from_plain_text(message)
    message.decoded.lines "\n"
  end

  def lines_from_html(mail)
    Nokogiri::HTML(mail.html_part.decoded).xpath("//text()[not(ancestor::style)]").map do |node|
      node.xpath('normalize-space()')
    end
  end
end
