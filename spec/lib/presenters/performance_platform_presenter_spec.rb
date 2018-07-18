describe PerformancePlatformPresenter do
  let(:stats) do
    {
      today: 12,
      cumulative: 24,
      sms_today: 2,
      sms_cumulative: 3,
      email_today: 10,
      email_cumulative: 21,
      sponsored_today: 7,
      sponsored_cumulative: 9
    }
  end

  subject { described_class.new(stats: stats).present }

  before do
    allow_any_instance_of(described_class).to \
      receive(:generate_timestamp).and_return('2018-07-16T00:00:00+00:00')
  end

  it 'returns formatted data' do
    expect(subject).to eq([
      {
        _id: 'MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdndpZmlkYXl2b2x1bWV0cmljc2FsbC1zaWduLXVwcw==',
        _timestamp: '2018-07-16T00:00:00+00:00',
        dataType: 'volumetrics',
        period: 'day',
        channel: 'all-sign-ups',
        count: 12,
        cumulative_count: 24
      },
      {
        _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdndpZmlkYXl2b2x1bWV0cmljc3Ntcy1zaWduLXVwcw==",
        _timestamp: '2018-07-16T00:00:00+00:00',
        dataType: 'volumetrics',
        period: 'day',
        channel: 'sms-sign-ups',
        count: 2,
        cumulative_count: 3
      },
      {
        _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdndpZmlkYXl2b2x1bWV0cmljc2VtYWlsLXNpZ24tdXBz",
        _timestamp: '2018-07-16T00:00:00+00:00',
        dataType: 'volumetrics',
        period: 'day',
        channel: 'email-sign-ups',
        count: 10,
        cumulative_count: 21
      },
      {
        _id: "MjAxOC0wNy0xNlQwMDowMDowMCswMDowMGdvdndpZmlkYXl2b2x1bWV0cmljc3Nwb25zb3JlZC1zaWduLXVwcw==",
        _timestamp: '2018-07-16T00:00:00+00:00',
        dataType: 'volumetrics',
        period: 'day',
        channel: 'sponsored-sign-ups',
        count: 7,
        cumulative_count: 9
      }
    ])
  end
end
