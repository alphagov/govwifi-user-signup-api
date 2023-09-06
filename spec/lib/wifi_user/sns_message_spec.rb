describe WifiUser::SnsMessage do
  describe "parsing the request" do
    let(:body) do
      '{
        "Type":"Notification",
        "Message":"{\"mail\":{\"messageId\":\"123\",\"commonHeaders\":{\"from\":[\"bob@gov.uk\"],\"to\":[\"sally@gov.uk\"]}},\"receipt\":{\"action\":{\"objectKey\":\"some-object-key\",\"bucketName\":\"some-bucket-name\"}}}"
      }'
    end
    subject(:sns_message) { WifiUser::SnsMessage.new(body:) }

    it "returns the type" do
      expect(sns_message.type).to eq("Notification")
    end
    it "returns the message_id" do
      expect(sns_message.message_id).to eq("123")
    end
    it "returns the from_address" do
      expect(sns_message.from_address).to eq("bob@gov.uk")
    end
    it "returns the message_id" do
      expect(sns_message.to_address).to eq("sally@gov.uk")
    end
    it "returns the message_id" do
      expect(sns_message.s3_object_key).to eq("some-object-key")
    end
    it "returns the message_id" do
      expect(sns_message.s3_bucket_name).to eq("some-bucket-name")
    end
    it "is not a sponsor" do
      expect(sns_message.sponsor_request?).to be false
    end
    it "is a sponsor" do
      body.sub!("sally@gov.uk", "sponsor@gov.uk")
      expect(sns_message.sponsor_request?).to be true
    end
  end
end
