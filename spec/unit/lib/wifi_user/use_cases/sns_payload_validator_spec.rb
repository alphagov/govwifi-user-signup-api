require 'openssl'

describe WifiUser::UseCase::SnsPayloadValidator do
  let(:subject) { described_class.new(expected_account_id: expected_account_id) }

  let(:account_id) { '012456353' }
  let(:expected_account_id) { account_id }
  let(:arn) { "arn:aws:sns:eu-west-2:#{account_id}:topic-name" }
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:public_key) { private_key.public_key }
  let(:signing_url) { 'https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem' }
  let(:certificate) { generate_certificate(private_key) }

  let(:payload_for_signing) do
    {
      'Message' => 'Some topic message',
      'MessageId' => '4d4dc071-ddbf-465d-bba8-08f81c89da64',
      'Subject' => 'My subject',
      'Timestamp' => '2012-06-05T04:37:04.321Z',
      'TopicArn' => arn,
      'Type' => 'Notification',
      'SignatureVersion' => '1',
      'UnsubscribeURL' => '',
      'SigningCertURL' => signing_url
    }
  end
  let(:signature) { generate_signature(payload_for_signing, private_key) }
  let(:payload) do
    payload_for_signing.merge({'Signature' => signature})
  end

  before do
    stub_request(:get, signing_url).to_return(body: certificate.to_pem)
  end
  
  it 'validates a valid payload' do
    expect(subject.execute(payload)).to eq(true)
  end

  context 'with an incorrect account ID' do
    let(:expected_account_id) { '353' }

    it 'fails validation' do
      #require 'pry'; binding.pry
      expect(subject.execute(payload)).to eq(false)
    end
  end

  context 'with an invalid signature' do
    let(:signature) { generate_signature(payload_for_signing, OpenSSL::PKey::RSA.new(2048)) }

    it 'fails validation' do
      expect(subject.execute(payload)).to eq(false)
    end
  end

  def generate_signature(payload, private_key)
    message = <<~HEREDOC
      Message
      #{payload['Message']}
      MessageId
      #{payload['MessageId']}
      Subject
      #{payload['Subject']}
      Timestamp
      #{payload['Timestamp']}
      TopicArn
      #{payload['TopicArn']}
      Type
      #{payload['Type']}
    HEREDOC
    Base64.strict_encode64(private_key.sign(OpenSSL::Digest::SHA1.new, message))
  end

  def generate_certificate(private_key)
    OpenSSL::X509::Certificate.new.tap do |cert|
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse('/C=BE/O=Test/OU=Test/CN=Test')
      cert.not_before = Time.now
      cert.not_after = Time.now + 365 * 24 * 60 * 60
      cert.public_key = private_key.public_key
      cert.serial = 0x0
      cert.version = 2
      cert.sign(private_key, OpenSSL::Digest::SHA1.new)
    end
  end
end
