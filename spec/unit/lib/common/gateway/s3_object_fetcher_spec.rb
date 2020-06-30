require "time"

describe Common::Gateway::S3ObjectFetcher do
  let(:bucket) { "StubBucket" }
  let(:key) { "StubKey" }
  let(:object_content) { "StubResponse" }

  subject { described_class.new(bucket: bucket, key: key) }

  before do
    ENV["AWS_CONTAINER_CREDENTIALS_RELATIVE_URI"] = "/stubUri"
    stub_request(:get, "http://169.254.170.2/stubUri").to_return(body: {
      'AccessKeyId': "ACCESS_KEY_ID",
      'Expiration': (Time.now + 60).iso8601,
      'RoleArn': "TASK_ROLE_ARN",
      'SecretAccessKey': "SECRET_ACCESS_KEY",
      'Token': "SECURITY_TOKEN_STRING"
    }.to_json)

    stub_request(:get, "https://s3.eu-west-1.amazonaws.com/#{bucket}/#{key}") \
      .to_return(body: object_content)
  end

  it "Returns the object contents" do
    expect(subject.fetch).to eq(object_content)
  end
end
