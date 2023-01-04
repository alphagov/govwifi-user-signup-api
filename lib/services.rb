class Services
  def self.s3_client
    Aws::S3::Client.new(region: "eu-west-2")
  end

  def self.notify_client
    Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
  end
end
