describe EmailSponseesExtractor do
  let(:email) { Mail.new }
  let(:sponsees) { subject.execute(email.to_s) }

  it 'Grabs a single email address' do
    email.body = 'adrian@example.com'
    expect(sponsees).to eq(['adrian@example.com'])
  end

  it 'Ignores an empty line a single email address' do
    email.body = "\nadrian@example.com"
    expect(sponsees).to eq(['adrian@example.com'])
  end

  it 'Plain text email with two sponsees' do
    email.body = "adrian@example.com\r\nchris@example.com"
    expect(sponsees).to eq(['adrian@example.com', 'chris@example.com'])
  end

  it 'Gets email addresses from a multipart email with one text part' do
    set_text_part("derick@example.com\r\ndan@example.com")
    expect(sponsees).to eq(['derick@example.com', 'dan@example.com'])
  end

  it 'Gets an email address from a multipart email with html part' do
    set_html_part('rick@example.com')
    expect(sponsees).to eq(['rick@example.com'])
  end

  it 'Ignores HTML from a multipart email with html part' do
    set_html_part('<body><p>steve@example.com</p><p>dan@example.com</p></body>')
    expect(sponsees).to eq(['steve@example.com', 'dan@example.com'])
  end

  it 'Ignores style tag from a multipart email with html part' do
    set_html_part('<body><style>body {}</style><p>dan@example.com</p></body>')
    expect(sponsees).to eq(['dan@example.com'])
  end

  it 'Returns empty array from an email with invalid HTML' do
    set_html_part('<body><asd')
    expect(sponsees).to eq([])
  end

  it 'Uses the text multipart over the html multipart' do
    set_html_part('rick@example.com')
    set_text_part('steve@example.com')
    expect(sponsees).to eq(['steve@example.com'])
  end

  context 'Regression tests' do
    it 'Multipart message' do
      sponsees = test_case 'email-sponsor-multipart'
      expect(sponsees.first).to eq('07123456789')
    end

    it 'Multiple levels of multipart messages' do
      sponsees = test_case 'email-sponsor-multilevel-multipart'
      expect(sponsees.first).to eq('example.user2@example.co.uk')
    end

    it 'Base64 encoded message' do
      sponsees = test_case('email-sponsor-base64')
      expect(sponsees).to eq(['example.user2@example.co.uk', '07123456789'])
    end

    it 'Base64 encoded HTML message' do
      sponsees = test_case 'email-sponsor-base64-htmlonly'
      expect(sponsees).to eq(['example.user2@example.co.uk', '07123456789'])
    end

    def test_case(regression_test_name)
      subject.execute(File.read("spec/fixtures/#{regression_test_name}.txt"))
    end
  end

  def set_text_part(text)
    email.parts << Mail::Part.new(body: text)
  end

  def set_html_part(html)
    email.parts << Mail::Part.new(content_type: 'text/html; charset=UTF-8', body: html)
  end
end
