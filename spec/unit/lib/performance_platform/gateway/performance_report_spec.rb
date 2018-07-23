describe PerformancePlatform::Gateway::PerformanceReport do
  let(:endpoint) { 'https://performance-platform/' }
  let(:data) { { metric_name: 'volumetrics', payload: [{ foo: :bar }] } }

  before do
    ENV['PERFORMANCE_BEARER_VOLUMETRICS'] = 'foobarbaz'
    ENV['PERFORMANCE_URL'] = endpoint

    stub_request(:post, "#{endpoint}data/gov-wifi/volumetrics")
    .with(
      body: data[:payload].to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer foobarbaz"
      }
    )
    .to_return(
      body: response.to_json,
      status: response_code
    )
  end

  context 'with valid data sent' do
    let(:response) { { status: 'ok' } }
    let(:response_code) { 200 }

    it 'returns an OK response' do
      result = subject.send_stats(data)

      expect(result['status']).to eq('ok')
    end
  end

  context 'with invalid data' do
    let(:response) { 'error message' }
    let(:response_code) { 403 }

    it 'rasises an error' do
      expect { subject.send_stats(data) }.to \
        raise_error(PerformancePlatform::Gateway::HttpError, '403 - "error message"')
    end
  end
end
