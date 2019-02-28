describe WifiUser::UseCase::ParseEmailRequest do
  describe 'parsing the request' do
    it 'returns the type when one is present' do
      request = '{
        "Type":"Notification",
        "Message":"{\"mail\":{\"messageId\":\"123\",\"commonHeaders\":{\"from\":[\"bob@gov.uk\"],\"to\":[\"sally@gov.uk\"]}},\"receipt\":{\"action\":{\"objectKey\":\"some-object-key\",\"bucketName\":\"some-bucket-name\"}}}"
      }'

      expected_result = {
        type: 'Notification',
        message_id: '123',
        from_address: 'bob@gov.uk',
        to_address: 'sally@gov.uk',
        s3_object_key: 'some-object-key',
        s3_bucket_name: 'some-bucket-name'
      }

      expect(subject.execute(request)).to eq(expected_result)
    end
  end
end
