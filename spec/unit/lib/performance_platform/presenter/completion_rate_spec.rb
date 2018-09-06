require 'timecop'

describe PerformancePlatform::Presenter::CompletionRate do
  before do
    Timecop.freeze(Date.parse('04-04-2018'))
  end

  after do
    Timecop.return
  end

  let(:stats) do
    {
      period: 'week',
      metric_name: 'completion-rate',
      sms_registered: 0,
      sms_logged_in: 0,
      email_registered: 0,
      email_logged_in: 0,
      sponsor_registered: 0,
      sponsor_logged_in: 0
    }
  end

  it 'presents the correct ID' do
    expected_id = 'MjAxOC0wNC0wNFQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0c21z'
    expect(subject.present(stats: stats)[:payload].first).to include(
      _id: expected_id,
      _timestamp: '2018-04-04T00:00:00+00:00'
    )
  end

  context 'Given a date override' do
    subject { described_class.new(date: '04-04-2018') }

    context 'Same date as today' do
      it 'does not change the identifier' do
        expected_id = 'MjAxOC0wNC0wNFQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0c21z'
        expect(subject.present(stats: stats)[:payload].first).to include(
          _id: expected_id,
          _timestamp: '2018-04-04T00:00:00+00:00'
        )
      end
    end

    context 'Given a different date to override' do
      subject { described_class.new(date: '05-04-2018') }

      it 'changes the identifier' do
        expected_id = 'MjAxOC0wNC0wNVQwMDowMDowMCswMDowMGdvdi13aWZpd2Vla2NvbXBsZXRpb24tcmF0ZXN0YXJ0c21z'
        expect(subject.present(stats: stats)[:payload].first).to include(
          _id: expected_id,
          _timestamp: '2018-04-05T00:00:00+00:00'
        )
      end
    end
  end
end
