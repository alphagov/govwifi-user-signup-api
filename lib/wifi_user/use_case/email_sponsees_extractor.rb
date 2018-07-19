require 'nokogiri'

class WifiUser::UseCase::EmailSponseesExtractor
  def initialize(email_fetcher:)
    @email_fetcher = email_fetcher
  end

  def execute
    mail = Mail.read_from_string(email_fetcher.fetch)

    contacts_from_mail(mail).map(&:strip).reject(&:empty?)
  end

private

  attr_reader :email_fetcher

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
