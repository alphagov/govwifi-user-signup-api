describe PerformancePlatform::Gateway::Volumetrics do
  let(:user_repository) { WifiUser::Repository::User }

  before do
    DB[:userdetails].truncate
  end

  context "given no signups" do
    it "returns stats with zero signups" do
      expect(subject.fetch_stats).to eq(
        period_before: 0,
        cumulative: 0,
        sms_period_before: 0,
        sms_cumulative: 0,
        metric_name: "volumetrics",
        period: "day",
        email_period_before: 0,
        email_cumulative: 0,
        sponsored_cumulative: 0,
        sponsored_period_before: 0
      )
    end
  end

  context "with user sign up date being a full timestamp" do
    before do
      user_repository.create(username: "full", created_at: Time.at(Time.now.to_i - 86400))
    end

    it "compares sign up creation date by date only" do
      expect(subject.fetch_stats[:period_before]).to eq(1)
    end
  end

  context "given 3 signups yesterday" do
    before do
      3.times do |i|
        user_repository.create(username: "new #{i}", created_at: Date.today - 1)
      end
    end

    it "returns signups for yesterday" do
      expect(subject.fetch_stats[:period_before]).to eq(3)
    end

    it "returns same cumulative number of signups" do
      expect(subject.fetch_stats[:cumulative]).to eq(3)
    end
  end

  context "given 5 signups yesterday and 1 day before that" do
    before do
      user_repository.create(username: "old", created_at: Date.today - 2)

      5.times do |i|
        user_repository.create(username: "new #{i}", created_at: Date.today - 1)
      end
    end

    it "returns zero signups 5 signups for yesterday" do
      expect(subject.fetch_stats[:period_before]).to eq(5)
    end

    it "returns zero signups 6 signups cumulative" do
      expect(subject.fetch_stats[:cumulative]).to eq(6)
    end
  end

  context "given 2 signups today" do
    before do
      2.times do |i|
        user_repository.create(username: i, created_at: Date.today)
      end
    end

    it "returns zero signups for yesterday" do
      expect(subject.fetch_stats[:period_before]).to eq(0)
    end

    it "returns zero signups cumulative" do
      expect(subject.fetch_stats[:cumulative]).to eq(0)
    end
  end

  context "given 1 SMS signup yesterday and 2 email signups" do
    before do
      user_repository.create(
        username: "Email 1",
        contact: "foo@bar.com",
        sponsor: "foo@bar.com",
        created_at: Date.today - 1
        )

      user_repository.create(
        username: "Email 2",
        contact: "foo@baz.com",
        sponsor: "foo@baz.com",
        created_at: Date.today - 1
        )

      user_repository.create(
        username: "SMS",
        contact: "+0123456789",
        sponsor: "+0123456789",
        created_at: Date.today - 1
        )
    end

    it "counts all of them against cumulative singups" do
      expect(subject.fetch_stats[:cumulative]).to eq(3)
    end

    it "counts all of them against yesterdays signups" do
      expect(subject.fetch_stats[:period_before]).to eq(3)
    end

    it "calculates SMS cumulative signups" do
      expect(subject.fetch_stats[:sms_cumulative]).to eq(1)
    end

    it "calculates SMS yesterdays signups" do
      expect(subject.fetch_stats[:sms_period_before]).to eq(1)
    end

    it "calculates email cumulative signups" do
      expect(subject.fetch_stats[:email_cumulative]).to eq(2)
    end

    it "calculates email yesterdays signups" do
      expect(subject.fetch_stats[:email_period_before]).to eq(2)
    end
  end

  context "given SMS signups made on different dates" do
    before do
      user_repository.create(
        username: "SMS old",
        created_at: Date.today - 6,
        contact: "+1123456789",
        sponsor: "+1123456789"
        )

      user_repository.create(
        username: "SMS new",
        contact: "+0123456789",
        sponsor: "+0123456789",
        created_at: Date.today - 1
        )
    end

    it "counts them against cumulative singups" do
      expect(subject.fetch_stats[:cumulative]).to eq(2)
    end

    it "counts them against yesterdays signups" do
      expect(subject.fetch_stats[:period_before]).to eq(1)
    end

    it "counts them against SMS cumulative signups" do
      expect(subject.fetch_stats[:sms_cumulative]).to eq(2)
    end

    it "counts them against SMS yesterdays signups" do
      expect(subject.fetch_stats[:sms_period_before]).to eq(1)
    end
  end

  context "given email signups made on different dates" do
    before do
      user_repository.create(
        username: "Email old",
        created_at: Date.today - 5,
        contact: "foo@bar.com",
        sponsor: "foo@bar.com"
        )

      user_repository.create(
        username: "Email new",
        contact: "foo@baz.com",
        sponsor: "foo@baz.com",
        created_at: Date.today - 1
        )
    end

    it "counts them against cumulative singups" do
      expect(subject.fetch_stats[:cumulative]).to eq(2)
    end

    it "counts them against yesterdays signups" do
      expect(subject.fetch_stats[:period_before]).to eq(1)
    end

    it "counts them against email cumulative signups" do
      expect(subject.fetch_stats[:email_cumulative]).to eq(2)
    end

    it "counts them against email signups yesterday" do
      expect(subject.fetch_stats[:email_period_before]).to eq(1)
    end
  end

  context "given sponsored sign ups" do
    before do
      user_repository.create(
        username: "Email",
        contact: "foo@bar.com",
        sponsor: "sponsor@bar.com",
        created_at: Date.today - 1
        )

      user_repository.create(
        username: "SMS",
        contact: "foo@baz.com",
        sponsor: "sponsor@baz.com",
        created_at: Date.today - 2
        )
    end

    it "counts both of them to cumulative number of sponsored sign ups" do
      expect(subject.fetch_stats[:sponsored_cumulative]).to eq(2)
    end

    it "counts one of them as sponsored sign up yesterday" do
      expect(subject.fetch_stats[:sponsored_period_before]).to eq(1)
    end
  end

  context "Date override" do
    subject { described_class.new(date: "2018-08-10") }

    before do
      user_repository.create(
        username: "Email",
        contact: "foo@bar.com",
        sponsor: "sponsor@bar.com",
        created_at: "2018-08-09"
        )

      user_repository.create(
        username: "SMS",
        contact: "foo@baz.com",
        sponsor: "sponsor@baz.com",
        created_at: "2018-08-29"
        )
    end

    it "counts both of them to cumulative number of sponsored sign ups" do
      expect(subject.fetch_stats[:sponsored_cumulative]).to eq(1)
    end

    it "counts one of them as sponsored sign up yesterday" do
      expect(subject.fetch_stats[:sponsored_period_before]).to eq(1)
    end
  end

  context "Stats for month" do
    subject { described_class.new(period: "month") }

    before do
      yesterday = Date.today.prev_day
      user_repository.create(username: "Email", contact: "foo@bar.com", created_at: yesterday.prev_month)
      user_repository.create(username: "SMS", contact: "1234567", created_at: yesterday.prev_day)
      user_repository.create(username: "Notme", contact: "2345678", created_at: yesterday.prev_month.prev_day)
    end

    it "counts signups for the previous month" do
      expect(subject.fetch_stats[:period_before]).to eq(2)
    end
  end
end
