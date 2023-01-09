describe WifiUser::UseCase::EmailSponseesExtractor do
  let(:request_body) { FactoryBot.create(:request_body, from: "Sponsor <sponsor@example.com>").to_json }
  let(:sns_message) { WifiUser::SnsMessage.new(body: request_body) }
  let(:sponsees) { subject.execute }
  let(:bucket_name) { sns_message.s3_bucket_name }
  let(:object_key) { sns_message.s3_object_key }

  subject { described_class.new(sns_message:) }

  it "Finds no email address or phone number" do
    write_email_to_s3(body: "somethinn\nsomething else", bucket_name:, object_key:)
    expect(sponsees).to be_empty
  end

  it "Grabs a single email address" do
    write_email_to_s3(body: "adrian@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com"])
  end

  it "Ignores an empty line a single email address" do
    write_email_to_s3(body: "\nadrian@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com"])
  end

  it "Ignores lines without email addresses of phone numbers" do
    write_email_to_s3(body: "something something\nadrian@example.com\nsomething something", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com"])
  end

  it "Plain text email with two sponsees" do
    write_email_to_s3(body: "adrian@example.com\r\nchris@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com", "chris@example.com"])
  end

  it "Gets email addresses from a multipart email with one text part" do
    write_email_to_s3(text_part: "derick@example.com\r\ndan@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["derick@example.com", "dan@example.com"])
  end

  it "Gets an email address from a multipart email with html part" do
    write_email_to_s3(html_part: "rick@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["rick@example.com"])
  end

  it "Ignores HTML from a multipart email with html part" do
    write_email_to_s3(html_part: "<body><p>steve@example.com</p><p>dan@example.com</p></body>", bucket_name:, object_key:)
    expect(sponsees).to eq(["steve@example.com", "dan@example.com"])
  end

  it "Ignores style tag from a multipart email with html part" do
    write_email_to_s3(html_part: "<body><style>body {}</style><p>dan@example.com</p></body>", bucket_name:, object_key:)
    expect(sponsees).to eq(["dan@example.com"])
  end

  it "Returns empty array from an email with invalid HTML" do
    write_email_to_s3(html_part: "<body><asd", bucket_name:, object_key:)
    expect(sponsees).to eq([])
  end

  it "Uses the text multipart over the html multipart" do
    write_email_to_s3(html_part: "rick@example.com", bucket_name:, object_key:)
    write_email_to_s3(text_part: "steve@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["steve@example.com"])
  end

  it "Filters the sponsor address from results" do
    write_email_to_s3(body: "adrian@example.com\r\nchris@example.com\r\nsponsor@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com", "chris@example.com"])
  end

  it "internationalises phone numbers" do
    write_email_to_s3(body: "  07701001111   ", bucket_name:, object_key:)
    expect(sponsees).to eq(["+447701001111"])
  end

  it "prefers email addresses over phone numbers if on the same line" do
    write_email_to_s3(body: "07701001111 adrian@example.com", bucket_name:, object_key:)
    expect(sponsees).to eq(["adrian@example.com"])
  end

  it "extracts both email addresses and phone numbers if not on the same line" do
    write_email_to_s3(body: "07701001111\nadrian@example.com", bucket_name:, object_key:)
    expect(sponsees).to match_array(["adrian@example.com", "+447701001111"])
  end

  context "Regression tests" do
    it "Multipart message" do
      test_case "email-sponsor-multipart"
      expect(sponsees.first).to eq("+447123456789")
    end

    it "Multiple levels of multipart messages" do
      test_case "email-sponsor-multilevel-multipart"
      expect(sponsees.first).to eq("example.user2@example.co.uk")
    end

    it "Base64 encoded message" do
      test_case "email-sponsor-base64"
      expect(sponsees).to eq(["example.user2@example.co.uk", "+447123456789"])
    end

    it "Base64 encoded HTML message" do
      test_case "email-sponsor-base64-htmlonly"
      expect(sponsees).to eq(["example.user2@example.co.uk", "+447123456789"])
    end

    def test_case(regression_test_name)
      test_raw_email = File.read("spec/fixtures/#{regression_test_name}.txt")
      Services.s3_client.put_object(bucket: sns_message.s3_bucket_name,
                                    key: sns_message.s3_object_key,
                                    body: test_raw_email)
    end
  end
end
