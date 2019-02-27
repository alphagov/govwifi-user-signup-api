require 'aws-sdk-s3'

class Common::Gateway::S3ObjectFetcher
  def initialize(bucket:, key:, region: 'eu-west-1')
    @bucket = bucket
    @key = key
    @region = region
  end

  def fetch
    s3 = Aws::S3::Resource.new(region: region)
    object = s3.bucket(bucket).object(key)
    object.get.body.read
  end

private

  attr_reader :bucket, :key, :region
end
