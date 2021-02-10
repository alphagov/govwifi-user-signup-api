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

  context "when the same message received three times in 15 minutes" do
    it "returns true" do
      subject.execute(number, message)
      subject.execute(number, message)

      expect(subject.execute(number, message)).to be true
    end
  end

  context "when the same message received three times but not within 15 minutes" do
    it "returns false" do
      subject.execute(number, message)
      DB[:smslog].update(created_at: Time.now - (16 * 60))
      subject.execute(number, message)

      expect(subject.execute(number, message)).to be false
    end
  end

  context "when any message received three times in 5 minutes" do
    it "returns true" do
      subject.execute(number, "foo")
      subject.execute(number, "bar")

      expect(subject.execute(number, "baz")).to be true
    end
  end

  context "when any message received three times but not within 5 minutes" do
    it "returns false" do
      subject.execute(number, "foo")
      DB[:smslog].update(created_at: Time.now - (6 * 60))
      subject.execute(number, "bar")

      expect(subject.execute(number, "baz")).to be false
    end
  end

  context "when there are logged messages older than CLEANUP_AFTER_MINUTES" do
    it "deletes the old records" do
      subject.execute(number, "foo")
      subject.execute(number, "bar")
      subject.execute(number, "baz")
      DB[:smslog].update(created_at: Time.now - (35 * 60))
      subject.execute(number, "qux")

      expect(DB[:smslog].count).to be(1)
    end
  end
end
