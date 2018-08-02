describe PerformancePlatform::UseCase::SendPerformanceReport do
  let(:performance_gateway) { PerformancePlatform::Gateway::PerformanceReport.new }
  let(:endpoint) { 'https://performance-platform/' }
  let(:response) { { status: 'ok' } }

  before do
    allow(presenter).to receive(:generate_timestamp).and_return('2018-07-16T00:00:00+00:00')

    expect(stats_gateway).to receive(:fetch_stats)
      .and_return(stats_gateway_response)

    ENV['PERFORMANCE_BEARER_VOLUMETRICS'] = 'foobarbaz'
    ENV['PERFORMANCE_BEARER_COMPLETION_RATE'] = 'googoogoo'
    ENV['PERFORMANCE_URL'] = endpoint
    ENV['PERFORMANCE_DATASET'] = dataset

    stub_request(:post, "#{endpoint}data/#{dataset}/#{metric}")
    .with(
      body: data[:payload].to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{bearer_token}"
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
      performance_gateway: performance_gateway,
      logger: double(info: '')
    )
  end

  context 'report for volumetrics' do
    let(:metric) { 'volumetrics' }
    let(:bearer_token) { 'foobarbaz' }
    let(:dataset) { 'gov-wifi' }
    let(:presenter) { PerformancePlatform::Presenter::Volumetrics.new }
    let(:stats_gateway) { PerformancePlatform::Gateway::Volumetrics.new }
    let(:stats_gateway_response) {
      {
        metric_name: 'volumetrics',
        period: 'day',
        yesterday: 12,
        cumulative: 24,
        sms_yesterday: 2,
        sms_cumulative: 3,
        email_yesterday: 10,
        email_cumulative: 21,
        sponsored_yesterday: 7,
        sponsored_cumulative: 9
      }
    }
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

    it 'fetches stats and sends them to Performance service' do
      expect(subject.execute(presenter: presenter)['status']).to eq('ok')
    end
  end

  context 'report for completion rates' do
    let(:metric) { 'completion-rate' }
    let(:bearer_token) { 'googoogoo' }
    let(:dataset) { 'gov-wifi' }
    let(:presenter) { PerformancePlatform::Presenter::CompletionRate.new }
    let(:stats_gateway) { PerformancePlatform::Gateway::CompletionRate.new }
    let(:stats_gateway_response) {
      {
        metric_name: 'completion-rate',
        period: 'week',
        sms_registered: 4,
        sms_logged_in: 2,
        email_registered: 2,
        email_logged_in: 1,
        sponsor_registered: 2,
        sponsor_logged_in: 1,
      }
    }

    let(:data) {
      {
        metric_name: "completion-rate",
        payload: [
          {
            _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0c21z",
            _timestamp: "2018-07-16T00:00:00+00:00",
            dataType: "completion-rate",
            period: "week",
            channel: "sms",
            stage: "start",
            count: 4
          },
          {
            _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZWNvbXBsZXRlc21z",
            _timestamp: "2018-07-16T00:00:00+00:00",
             dataType: "completion-rate",
             period: "week",
             channel: "sms",
             stage: "complete",
             count: 2
          },
          {
            _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0ZW1haWw=",
            _timestamp: "2018-07-16T00:00:00+00:00",
            dataType: "completion-rate",
            period: "week",
            channel: "email",
            stage: "start",
            count: 2
          },
          {
            _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZWNvbXBsZXRlZW1haWw=",
            _timestamp: "2018-07-16T00:00:00+00:00",
             dataType: "completion-rate",
             period: "week",
             channel: "email",
             stage: "complete",
             count: 1
          },
          {
             _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0c3BvbnNvcg==",
             _timestamp: "2018-07-16T00:00:00+00:00",
              dataType: "completion-rate",
              period: "week",
              channel: "sponsor",
              stage: "start",
              count: 2
          },
          {

              _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZWNvbXBsZXRlc3BvbnNvcg==",
              _timestamp: "2018-07-16T00:00:00+00:00",
              dataType: "completion-rate",
              period: "week",
              channel: "sponsor",
              stage: "complete",
              count: 1
           }
         ]
       }
    }

    it 'fetches stats and sends them to Performance service' do
      expect(subject.execute(presenter: presenter)['status']).to eq('ok')
    end
  end
end
