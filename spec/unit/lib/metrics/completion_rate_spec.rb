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
    Metrics::CompletionRate.new(period: period,
                                date: start_date.to_s)
  end

  before do
    ENV["S3_METRICS_BUCKET"] = "stub-bucket"
    DB[:userdetails].truncate
    allow(Services).to receive(:s3_client).and_return s3_client
  end

  it "rejects invalid periods" do
    expect { Metrics::CompletionRate.new(period: "foo", date: Date.today.to_s) }
      .to raise_error(ArgumentError)
  end

  describe "#execute" do
    before do
      FactoryBot.create(:user_details, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, created_at: last_week)
      FactoryBot.create(:user_details, :not_logged_in, created_at: last_week)
      FactoryBot.create(:user_details, :not_logged_in, created_at: last_year)

      FactoryBot.create(:user_details, :sms, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, :sms, created_at: last_week)
      FactoryBot.create(:user_details, :sms, :not_logged_in, created_at: last_week)
      FactoryBot.create(:user_details, :sms, :not_logged_in, created_at: last_year)

      FactoryBot.create(:user_details, :self_signed, created_at: twelve_hours_ago)
      FactoryBot.create(:user_details, :self_signed, created_at: last_week)
      FactoryBot.create(:user_details, :not_logged_in, :self_signed, created_at: last_week)
      FactoryBot.create(:user_details, :not_logged_in, :self_signed, created_at: last_year)

      subject.execute

      result = s3_client.get_object(bucket: ENV.fetch("S3_METRICS_BUCKET"), key: subject.key).body.read
      @parsed_result = JSON.parse(result)
    end

    describe "The start date is yesterday and the period is a month" do
      let(:start_date) { yesterday }
      let(:period) { "month" }

      it "uploads information that 2 sms registered users were created within a month before yesterday" do
        expect(@parsed_result["sms_registered"]).to eq(2)
      end

      it "uploads information that 1 sms registered user was created within a month before yesterday who logged in" do
        expect(@parsed_result["sms_logged_in"]).to eq(1)
      end

      it "uploads information that 2 email registered users were created within a month before yesterday" do
        expect(@parsed_result["email_registered"]).to eq(2)
      end

      it "uploads information that 1 email registered user was created before yesterday within a month who logged in" do
        expect(@parsed_result["email_logged_in"]).to eq(1)
      end

      it "uploads information that 2 sponsored users were created before yesterday within a month" do
        expect(@parsed_result["sponsor_registered"]).to eq(2)
      end

      it "uploads information that 1 sponsored user was created before yesterday who logged in" do
        expect(@parsed_result["sponsor_logged_in"]).to eq(1)
      end
    end
  end
end
