require 'phonelib'

describe WifiUser::PhoneNumber do
  describe "#internationalise" do
    context "when given a valid UK mobile number" do
      it "internationalises a mobile number starting with '07'" do
        expect(WifiUser::PhoneNumber.internationalise("07701001111")).to eq("+447701001111")
      end
    end

    context "when given an already internationalised number" do
      it "does not change an already internationalised number" do
        expect(WifiUser::PhoneNumber.internationalise("+447701001111")).to eq("+447701001111")
      end
    end

    context "when given an invalid phone number" do
      it "raises an error for an invalid phone number" do
        expect { WifiUser::PhoneNumber.internationalise("12345") }.to raise_error('InvalidPhoneError: Not a valid country prefix')
      end

      it "raises an error for an incorrectly formatted phone number" do
        expect { WifiUser::PhoneNumber.internationalise("00+123456789") }.to raise_error('InvalidPhoneError: Not a valid country prefix')
      end
    end
  end

  describe "#extract_from" do
    context "when given valid input" do
      it "extracts and internationalises a phone number, ignoring all white space" do
        expect(WifiUser::PhoneNumber.extract_from(" + 44 77 01 00 1111 ")).to eq("+447701001111")
      end

      it "extracts and internationalises a mobile number" do
        expect(WifiUser::PhoneNumber.extract_from(" 077 01 00 1111")).to eq("+447701001111")
      end
    end

    context "when given invalid input" do
      it "returns nil when no valid phone number is found" do
        expect(WifiUser::PhoneNumber.extract_from(" something ")).to be_nil
      end

      it "returns nil when the text contains non-phone number characters and no valid phone number" do
        expect(WifiUser::PhoneNumber.extract_from(" something12345678something ")).to be_nil
      end
    end

    context "when handling edge cases" do
      it "returns nil for a phone number that's too short" do
        expect(WifiUser::PhoneNumber.extract_from("01234")).to be_nil
      end

      it "raises an error for an invalid international prefix" do
        expect { WifiUser::PhoneNumber.extract_from("+00 123456789") }.to raise_error('InvalidPhoneError: Not a valid country prefix')
      end

      it "extracts and internationalises a valid non-UK international number" do
        expect(WifiUser::PhoneNumber.extract_from("+1 234 567 8910")).to eq("+12345678910")
      end
    end
  end
end
