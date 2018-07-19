describe PerformancePlatform::UseCase::SendPerformanceReport do
  let(:stats_gateway) { PerformancePlatform::Gateway::Volumetrics.new }
  let(:performance_gateway) { PerformancePlatform::Gateway::PerformanceReport.new }
  let(:endpoint) { 'https://performance-platform/' }
  let(:response) { { status: 'ok' } }
  let(:data) {
    {
      metric_name: 'volumetrics',
      payload: [
        {
          _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NhbGwtc2lnbi11cHM=',
          _timestamp: '2018-07-16T00:00:00+00:00',
          dataType: 'volumetrics',
          period: 'day',
          channel: 'all-sign-ups',
          count: 12,
          cumulative_count: 24
        },
        {
          _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NzbXMtc2lnbi11cHM=',
          _timestamp: '2018-07-16T00:00:00+00:00',
          dataType: 'volumetrics',
          period: 'day',
          channel: 'sms-sign-ups',
          count: 2,
          cumulative_count: 3
        },
        {
          _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NlbWFpbC1zaWduLXVwcw==',
          _timestamp: '2018-07-16T00:00:00+00:00',
          dataType: 'volumetrics',
          period: 'day',
          channel: 'email-sign-ups',
          count: 10,
          cumulative_count: 21
        },
        {
          _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NzcG9uc29yZWQtc2lnbi11cHM=',
          _timestamp: '2018-07-16T00:00:00+00:00',
          dataType: 'volumetrics',
          period: 'day',
          channel: 'sponsored-sign-ups',
          count: 7,
          cumulative_count: 9
        }
      ]
    }
  }

  before do
    allow_any_instance_of(PerformancePlatform::Presenter::Report).to \
      receive(:generate_timestamp).and_return('2018-07-16T00:00:00+00:00')

    expect(stats_gateway).to receive(:fetch_stats)
      .and_return(
        metric_name: 'volumetrics',
        period: 'day',
        today: 12,
        cumulative: 24,
        sms_today: 2,
        sms_cumulative: 3,
        email_today: 10,
        email_cumulative: 21,
        sponsored_today: 7,
        sponsored_cumulative: 9
      )

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
      status: 200
    )
  end

  subject do
    described_class.new(
      stats_gateway: stats_gateway,
      performance_gateway: performance_gateway
    )
  end

  it 'fetches stats and sends them to Performance service' do
    expect(subject.execute['status']).to eq('ok')
  end
end
