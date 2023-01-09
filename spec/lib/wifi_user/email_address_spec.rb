describe WifiUser::EmailAddress do
  describe "#extract_from" do
    it "extracts an email address" do
      expect(WifiUser::EmailAddress.extract_from("something john@gov.uk something")).to eq("john@gov.uk")
    end
    it "extracts only the first email address" do
      expect(WifiUser::EmailAddress.extract_from("something john@gov.uk something jane@gov.uk")).to eq("john@gov.uk")
    end
    it "returns nil if no email address can be found" do
      expect(WifiUser::EmailAddress.extract_from("something something")).to be nil
    end
  end
end
