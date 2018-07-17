class PerformancePlatformGateway
  def send_stats(data)
    uri = URI("https://performance-platform/data")
    
    post(uri, data)
  end

private

  def post(uri, data)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = 'Bearer foobarbaz'
    request['Content-Type'] = 'application/json'
    request.body = data.to_json

    Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
      JSON.parse(http.request(request).body)
    end
  end
end