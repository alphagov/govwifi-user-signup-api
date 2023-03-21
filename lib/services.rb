class Services
  def self.s3_client(region: "eu-west-2")
    Aws::S3::Client.new(region:)
  end

  def self.notify_client
    Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
  end
end
