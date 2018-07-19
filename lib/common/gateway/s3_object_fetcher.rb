require 'aws-sdk-s3'

class Common::Gateway::S3ObjectFetcher
  def initialize(bucket:, key:)
    @bucket = bucket
    @key = key
  end

  def fetch
    s3 = Aws::S3::Resource.new(region: 'eu-west-1')
    object = s3.bucket(bucket).object(key)
    object.get.body.read
  end

private

  attr_reader :bucket, :key
end
