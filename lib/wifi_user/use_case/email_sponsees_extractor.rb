require "nokogiri"

class WifiUser::UseCase::EmailSponseesExtractor
  def initialize(email_fetcher:, exclude_addresses:, logger: Logger.new($stdout))
    @email_fetcher = email_fetcher
    @exclude_addresses = exclude_addresses
    @logger = logger
  end

  def execute
    normalised_exclude_addresses = @exclude_addresses.map { |addr| Mail::Address.new(addr).address }
    mail = Mail.read_from_string(email_fetcher.fetch)

    contacts_from_mail(mail).map(&:strip).reject(&:empty?)
      .reject { |contact| normalised_exclude_addresses.include?(contact) }
  rescue Mail::Field::ParseError => e
    @logger.warn("unable to parse address: #{e}")
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
      node.xpath("normalize-space()")
    end
  end
end
