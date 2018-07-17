describe PerformancePlatformGateway do
  let(:endpoint) { 'https://performance-platform/' }

  before do
    stub_request(:post, "#{endpoint}data")
    .with(
      body: data.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer foobarbaz'
      }
    )
    .to_return(
      body: response.to_json,
      status: 200
    )
  end

  context 'with valid data sent' do
    let(:data) { [{'metric1' => 'foobar'}] }
    let(:response) { { status: 'ok' } }

    it 'returns a valid response' do
      result = subject.send_stats(data)

      expect(result['status']).to eq('ok')
    end
  end
end