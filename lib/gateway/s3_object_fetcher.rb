require 'aws-sdk-s3'

class S3ObjectFetcher
  def initialize(bucket:, key:)
    @bucket = bucket
    @key = key
  end

  def fetch
    s3 = Aws::S3::Resource.new(region: 'us-west-2')
    object = s3.get_object(bucket: bucket, key: key)
    object.body.read
  end

private

  attr_reader :bucket, :key
end
