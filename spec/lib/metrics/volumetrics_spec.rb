# frozen_string_literal: true

require_relative "./s3_fake_client"

describe Metrics::Volumetrics do
  let(:today) { Date.today }
  let(:twelve_hours_ago) { today - 0.5 }
  let(:yesterday) { today - 1 }
  let(:two_days_ago) { today - 2 }
  let(:last_week) { today - 7 }
  let(:last_year) { today << 12 }
  let(:s3_client) { Metrics.fake_s3_client }

  subject do
    Metrics::Volumetrics.new(period: period,
                             date: start_date.to_s)
  end

  before do
    ENV["S3_METRICS_BUCKET"] = "stub-bucket"
    DB[:userdetails].truncate
    allow(Services).to receive(:s3_client).and_return s3_client
  end

  it "rejects invalid periods" do
    expect { Metrics::Volumetrics.new(period: "foo", date: Date.today.to_s) }
      .to raise_error(ArgumentError)
  end

  describe "#execute" do
    before do
      FactoryBot.create(:user_details, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, created_at: two_days_ago)
      FactoryBot.create(:user_details, created_at: last_week)
      FactoryBot.create(:user_details, created_at: last_year)
      FactoryBot.create(:user_details, :sms, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, :sms, created_at: two_days_ago)
      FactoryBot.create(:user_details, :sms, created_at: last_week)
      FactoryBot.create(:user_details, :sms, created_at: last_year)
      FactoryBot.create(:user_details, :self_signed, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, :self_signed, created_at: two_days_ago)
      FactoryBot.create(:user_details, :self_signed, created_at: last_week)
      FactoryBot.create(:user_details, :self_signed, created_at: last_year)

      subject.execute

      result = s3_client.get_object(bucket: ENV.fetch("S3_METRICS_BUCKET"), key: subject.key).body.read
      @parsed_result = JSON.parse(result)
    end

    describe "The start date is yesterday and the period is a month" do
      let(:start_date) { yesterday }
      let(:period) { "month" }

      it "uploads information that 6 users were created between yesterday and a month before" do
        expect(@parsed_result["period_before"]).to eq(6)
      end

      it "uploads information that 9 users were created before yesterday" do
        expect(@parsed_result["cumulative"]).to eq(9)
      end

      it "uploads information that 2 self signed SMS users were created between yesterday and a month before" do
        expect(@parsed_result["sms_period_before"]).to eq(2)
      end

      it "uploads information that 3 self signed SMS users were created before yesterday" do
        expect(@parsed_result["sms_cumulative"]).to eq(3)
      end

      it "uploads information that 2 self signed Email users were created between yesterday and a month before" do
        expect(@parsed_result["email_period_before"]).to eq(2)
      end

      it "uploads information that 3 self signed Email users were created before yesterday" do
        expect(@parsed_result["email_cumulative"]).to eq(3)
      end
    end

    describe "The start date is today and the period is a day" do
      let(:start_date) { today }
      let(:period) { "day" }

      it "uploads information that 3 users were created between today and yesterday" do
        expect(@parsed_result["period_before"]).to eq(3)
      end

      it "uploads information that 12 users were created before today" do
        expect(@parsed_result["cumulative"]).to eq(12)
      end

      it "uploads information that 1 self signed SMS user was created between today and yesterday" do
        expect(@parsed_result["sms_period_before"]).to eq(1)
      end

      it "uploads information that 4 self signed SMS users were created before today" do
        expect(@parsed_result["sms_cumulative"]).to eq(4)
      end

      it "uploads information that 1 self signed Email user was created between today and yesterday" do
        expect(@parsed_result["email_period_before"]).to eq(1)
      end

      it "uploads information that 4 self signed Email users were created before today" do
        expect(@parsed_result["email_cumulative"]).to eq(4)
      end
    end
  end
end
