require "aws-sdk-s3"

class Common::Gateway::S3ObjectFetcher
  def initialize(bucket:, key:, region: "eu-west-1")
    @bucket = bucket
    @key = key
    @region = region
  end

  def fetch
    s3 = Aws::S3::Resource.new(client: Services.s3_client, region:)
    object = s3.bucket(bucket).object(key)
    object.get.body.read
  end

  def self.allow_list_regexp
    Common::Gateway::S3ObjectFetcher.new(
      bucket: ENV.fetch("S3_SIGNUP_ALLOWLIST_BUCKET"),
      key: ENV.fetch("S3_SIGNUP_ALLOWLIST_OBJECT_KEY"),
      region: "eu-west-2",
    ).fetch
  end

  def self.sponsor_email(sns_message)
    Common::Gateway::S3ObjectFetcher.new(
      bucket: sns_message.s3_bucket_name,
      key: sns_message.s3_object_key,
    )
  end

private

  attr_reader :bucket, :key, :region
end
