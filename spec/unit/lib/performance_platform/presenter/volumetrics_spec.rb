require "timecop"

describe PerformancePlatform::Presenter::Volumetrics do
  before do
    Timecop.freeze(Date.parse("04-04-2018"))
  end

  after do
    Timecop.return
  end

  let(:stats) do
    {
      period: "day",
      metric_name: "volumetrics",
      period_before: 0,
      cumulative: 0,
      sms_period_before: 0,
      sms_cumulative: 0,
      email_period_before: 0,
      email_cumulative: 0,
      sponsored_period_before: 0,
      sponsored_cumulative: 0
    }
  end

  it "presents the correct ID" do
    expected_id = "MjAxOC0wNC0wM1QwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NhbGwtc2lnbi11cHM="
    expect(subject.present(stats: stats)[:payload].first).to include(
      _id: expected_id,
      _timestamp: "2018-04-03T00:00:00+00:00"
    )
  end

  context "Given a date override" do
    subject { described_class.new(date: "04-04-2018") }

    context "Same date as today" do
      it "does not change the identifier" do
        expected_id = "MjAxOC0wNC0wM1QwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NhbGwtc2lnbi11cHM="
        expect(subject.present(stats: stats)[:payload].first).to include(
          _id: expected_id,
          _timestamp: "2018-04-03T00:00:00+00:00"
        )
      end
    end

    context "Given a different date to override" do
      subject { described_class.new(date: "05-04-2018") }

      it "changes the identifier" do
        expected_id = "MjAxOC0wNC0wNFQwMDowMDowMCswMDowMGdvdi13aWZpZGF5dm9sdW1ldHJpY3NhbGwtc2lnbi11cHM="
        expect(subject.present(stats: stats)[:payload].first).to include(
          _id: expected_id,
          _timestamp: "2018-04-04T00:00:00+00:00"
        )
      end
    end
  end
end
