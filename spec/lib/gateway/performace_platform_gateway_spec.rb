describe PerformancePlatformGateway do
  let(:endpoint) { 'https://performance-platform/' }

  before do
    ENV['PERFORMANCE_BEARER_VOLUMETRICS'] = 'foobarbaz'
    ENV['PERFORMANCE_URL'] = endpoint

    stub_request(:post, "#{endpoint}data/gov-wifi/volumetrics")
    .with(
      body: data.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer foobarbaz"
      }
    )
    .to_return(
      body: response.to_json,
      status: 200
    )
  end

  context 'with valid data sent' do
    let(:data) { [{ foo: :bar }] }
    let(:response) { { status: 'ok' } }

    it 'returns an OK response' do
      result = subject.send_stats(data)

      expect(result['status']).to eq('ok')
    end
  end
end
