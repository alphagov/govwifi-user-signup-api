describe WifiUser::UseCase::RepetitiveSmsChecker do
  subject { described_class.new(smslog_model: WifiUser::Repository::Smslog.new) }

  let(:number) { "NUMBER" }
  let(:message) { "Lorem ipsum dolor sit amet" }

  before(:each) do
    DB[:smslog].truncate
  end

  context "when the same message received once" do
    it "returns false" do
      expect(subject.execute(number, message)).to be false
    end
  end

  context "when the same message received NUMBER_AND_MESSAGE_THRESHOLD times in NUMBER_AND_MESSAGE_MINUTES minutes" do
    it "returns true" do
      (described_class::NUMBER_AND_MESSAGE_THRESHOLD - 1).times do
        subject.execute(number, message)
      end

      expect(subject.execute(number, message)).to be true
    end
  end

  context "when the same message received NUMBER_THRESHOLD times but not within NUMBER_AND_MESSAGE_MINUTES minutes" do
    it "returns false" do
      (described_class::NUMBER_THRESHOLD - 2).times do
        subject.execute(number, message)
      end
      DB[:smslog].update(created_at: Time.now - ((described_class::NUMBER_AND_MESSAGE_MINUTES + 1) * 60))
      subject.execute(number, message)

      expect(subject.execute(number, message)).to be false
    end
  end

  context "when any message received NUMBER_THRESHOLD times in NUMBER_MINUTES minutes" do
    it "returns true" do
      (described_class::NUMBER_THRESHOLD - 1).times do |count|
        subject.execute(number, "#{message} #{count}")
      end

      expect(subject.execute(number, "baz")).to be true
    end
  end

  context "when any message received NUMBER_THRESHOLD times but not within NUMBER_MINUTES minutes" do
    it "returns false" do
      (described_class::NUMBER_THRESHOLD - 2).times do |count|
        subject.execute(number, "#{message} #{count}")
      end
      DB[:smslog].update(created_at: Time.now - ((described_class::NUMBER_MINUTES + 1) * 60))
      subject.execute(number, "bar")

      expect(subject.execute(number, "baz")).to be false
    end
  end

  context "when there are logged messages older than CLEANUP_AFTER_MINUTES" do
    it "deletes the old records" do
      subject.execute(number, "foo")
      subject.execute(number, "bar")
      subject.execute(number, "baz")
      DB[:smslog].update(created_at: Time.now - ((described_class::CLEANUP_AFTER_MINUTES + 5) * 60))
      subject.execute(number, "qux")

      expect(DB[:smslog].count).to be(1)
    end
  end

  context "when a received SMS has no number" do
    it "does not record a log" do
      subject.execute(nil, "foo")
      expect(DB[:smslog].count).to be(0)
    end
  end
end
