require "time"

describe Common::Gateway::S3ObjectFetcher do
  let(:bucket) { "StubBucket" }
  let(:key) { "StubKey" }
  let(:object_content) { "StubResponse" }

  subject { described_class.new(bucket:, key:) }

  before do
    Services.s3_client.put_object(bucket:, key:, body: object_content)
  end

  it "Returns the object contents" do
    expect(subject.fetch).to eq(object_content)
  end
end
