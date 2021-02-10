describe WifiUser::Repository::Smslog do
  before(:each) do
    DB[:smslog].truncate
  end

  let(:number) { "NUMBER" }
  let(:message) { "Lorem ipsum dolor sit amet" }

  describe "#create_log" do
    it "creates a record" do
      subject.create_log(number, message)

      expect(described_class[1].exists?).to be true
    end
  end

  describe "#get_matching" do
    context "when there are no records" do
      it "returns no results" do
        expect(subject.get_matching(number: number, message: message, within_minutes: 60).all).to be_empty
      end
    end

    context "when there are records" do
      it "returns matching messages with number and message" do
        described_class.insert(number: number, message: message)
        described_class.insert(number: "foo", message: "bar")
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)

        expect(subject.get_matching(number: number, message: message, within_minutes: 60).all.map(&:id)).to eq [1, 3, 4]
      end

      it "returns matching messages with number" do
        described_class.insert(number: number, message: "foo")
        described_class.insert(number: "foo", message: "bar")
        described_class.insert(number: number, message: "baz")
        described_class.insert(number: "bar", message: "qux")

        expect(subject.get_matching(number: number, within_minutes: 60).all.map(&:id)).to eq [1, 3]
      end

      it "doesn't include old messages" do
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)
        described_class.dataset.update(created_at: Time.now - (90 * 60))
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)

        expect(subject.get_matching(number: number, within_minutes: 60).all.map(&:id)).to eq [4, 5, 6]
      end

      it "cleans up old messages" do
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)
        described_class.insert(number: number, message: message)
        described_class.dataset.update(created_at: Time.now - (90 * 60))
        subject.cleanup(after_minutes: 60)
        expect(described_class.dataset.count).to eq(0)
      end
    end
  end
end
