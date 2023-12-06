describe WifiUser::PhoneNumber do
  describe "#internationalise" do
    it "internationalises a mobile number" do
      expect(WifiUser::PhoneNumber.internationalise("07701001111")).to eq("+447701001111")
    end
    it "does not internationalise an international number" do
      expect(WifiUser::PhoneNumber.internationalise("+447701001111")).to eq("+447701001111")
    end
  end
  describe "#extract_from" do
    it "extracts a phone number, ignoring all white space" do
      expect(WifiUser::PhoneNumber.extract_from(" + 44 77 01 00 1111 ")).to eq("+447701001111")
    end
    it "internationalises a mobile number" do
      expect(WifiUser::PhoneNumber.extract_from(" 077 01 00 1111")).to eq("+447701001111")
    end
    it "does not find a phone number and returns nil" do
      expect(WifiUser::PhoneNumber.extract_from(" something ")).to be nil
    end
    it "does not find a phone number when it contains nonsense and returns nil" do
      expect(WifiUser::PhoneNumber.extract_from(" something12345678something ")).to be nil
    end
  end
end
