class PerformancePlatform::Gateway::HttpError < StandardError; end

class PerformancePlatform::Gateway::PerformanceReport
  def send_stats(data)
    uri = build_url(data)

    post(uri, data)
  end

private

  def post(uri, data)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = build_bearer_token(data)
    request['Content-Type'] = 'application/json'
    request.body = data[:payload].to_json

    Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
      response = http.request(request)

      raise PerformancePlatform::Gateway::HttpError, "#{response.code} - #{response.body}" \
        unless response.code == '200'

      JSON.parse(response.body)
    end
  end

  def build_url(data)
    URI("#{ENV.fetch('PERFORMANCE_URL')}data/gov-wifi/#{data[:metric_name]}")
  end

  def build_bearer_token(data)
    bearer_const_name = data[:metric_name].tr('-', '_').upcase

    "Bearer #{ENV.fetch('PERFORMANCE_BEARER_' + bearer_const_name)}"
  end
end
