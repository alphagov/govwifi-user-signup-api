class Services
  def self.s3_client
    Aws::S3::Client.new(region: "eu-west-2")
  end
end
