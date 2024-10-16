describe WifiUser::UseCase::SmsTemplateFinder do
  subject { described_class.new }

  def template_for_message(sms_content)
    subject.execute(sms_content:)
  end

  context "Given there is a Go message" do
    it "returns the credentials template id" do
      expect(template_for_message("go")).to eq("credentials_sms")
      expect(template_for_message("Go")).to eq("credentials_sms")
      expect(template_for_message("GO")).to eq("credentials_sms")
    end
  end

  context "Given a help message" do
    context "on production" do
      it "returns the help menu template id" do
        expect(template_for_message("help")).to eq("help_menu_sms")
        expect(template_for_message("HELP")).to eq("help_menu_sms")
      end
    end
  end

  context "Given a message of 0" do
    context "on production" do
      it "returns the other device template" do
        expect(template_for_message("0")).to eq("device_help_other_sms")
        expect(template_for_message("other")).to eq("device_help_other_sms")
      end
    end
  end

  context "Given a message of 1" do
    it "returns the device template for Android" do
      expect(template_for_message("1")).to eq("device_help_android_sms")
      expect(template_for_message("1 ")).to eq("device_help_android_sms")
      expect(template_for_message(" hello 1 steve")).to eq("device_help_android_sms")
      expect(template_for_message("android")).to eq("device_help_android_sms")
      expect(template_for_message("samsung")).to eq("device_help_android_sms")
      expect(template_for_message("galaxy")).to eq("device_help_android_sms")
      expect(template_for_message("htc")).to eq("device_help_android_sms")
      expect(template_for_message("huawei")).to eq("device_help_android_sms")
      expect(template_for_message("sony")).to eq("device_help_android_sms")
      expect(template_for_message("motorola")).to eq("device_help_android_sms")
      expect(template_for_message("lg")).to eq("device_help_android_sms")
      expect(template_for_message("nexus")).to eq("device_help_android_sms")
    end
  end

  context "Given a message of 2" do
    it "returns the device template for iPhone" do
      expect(template_for_message("2")).to eq("device_help_iphone_sms")
      expect(template_for_message("iphone")).to eq("device_help_iphone_sms")
      expect(template_for_message("ios")).to eq("device_help_iphone_sms")
      expect(template_for_message("ipad")).to eq("device_help_iphone_sms")
    end
  end

  context "Given a message of 3" do
    it "returns the device template for Mac" do
      expect(template_for_message("3")).to eq("device_help_mac_sms")
      expect(template_for_message(" 3")).to eq("device_help_mac_sms")
      expect(template_for_message("mac")).to eq("device_help_mac_sms")
      expect(template_for_message("OSX")).to eq("device_help_mac_sms")
      expect(template_for_message("apple")).to eq("device_help_mac_sms")
      expect(template_for_message("hello 3 steve")).to eq("device_help_mac_sms")
    end
  end

  context "Given a message of 4" do
    it "returns the device template for Windows" do
      expect(template_for_message("4")).to eq("device_help_windows_sms")
      expect(template_for_message("windoWs")).to eq("device_help_windows_sms")
      expect(template_for_message("win")).to eq("device_help_windows_sms")
      expect(template_for_message(" 4")).to eq("device_help_windows_sms")
      expect(template_for_message("hello 4 steve")).to eq("device_help_windows_sms")
    end
  end

  context "Given a message of 6" do
    it "returns the device template for Chromebook" do
      expect(template_for_message("6")).to eq("device_help_chromebook_sms")
      expect(template_for_message(" 6")).to eq("device_help_chromebook_sms")
      expect(template_for_message("hello 6 steve")).to eq("device_help_chromebook_sms")
      expect(template_for_message("chromebook")).to eq("device_help_chromebook_sms")
      expect(template_for_message("hello chromebook steve")).to eq("device_help_chromebook_sms")
    end
  end

  context "Given no template could be derived" do
    it "returns the recap response" do
      expect(template_for_message("any unmatched content")).to eq("recap_sms")
    end
  end
end
