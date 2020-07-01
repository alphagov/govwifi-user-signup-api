describe WifiUser::UseCase::SmsTemplateFinder do
  let(:environment) { "production" }
  subject { described_class.new(environment: environment) }

  def template_for_message(message_content)
    subject.execute(message_content: message_content)
  end

  context "Given no message content" do
    context "on staging" do
      let(:environment) { "staging" }

      it "returns the credentials template id" do
        expect(template_for_message("")).to eq("24d47eb3-8b02-4eba-aa04-81ffaf4bb1b4")
      end
    end

    context "on production" do
      let(:environment) { "production" }

      it "returns the credentials template id" do
        expect(template_for_message("")).to eq("3a4b1ca8-7b26-4266-8b5f-e05fdbd11879")
        expect(template_for_message(" ")).to eq("3a4b1ca8-7b26-4266-8b5f-e05fdbd11879")
      end
    end
  end

  context "Given there is a Go message" do
    let(:credentials_template) { "3a4b1ca8-7b26-4266-8b5f-e05fdbd11879" }
    it "returns the credentials template id" do
      expect(template_for_message("go")).to eq(credentials_template)
      expect(template_for_message("Go")).to eq(credentials_template)
      expect(template_for_message("GO")).to eq(credentials_template)
    end
  end

  context "Given a help message" do
    context "on production" do
      it "returns the help menu template id" do
        expect(template_for_message("help")).to eq("2598f762-5c2f-4af8-9309-6ab932047010")
        expect(template_for_message("HELP")).to eq("2598f762-5c2f-4af8-9309-6ab932047010")
      end
    end
  end

  context "Given a message of 4" do
    let(:windows_template) { "801d5deb-6480-4fc6-91e1-da9f5f290c0b" }
    it "returns the device template for Windows" do
      expect(template_for_message("4")).to eq(windows_template)
      expect(template_for_message(" 4")).to eq(windows_template)
      expect(template_for_message("hello 4 steve")).to eq(windows_template)
    end
  end

  context "Given a message of 2" do
    it "returns the device template for iPhone" do
      expect(template_for_message("2")).to eq("ab535538-dc2e-4410-8b40-50fcc852f8bd")
      expect(template_for_message("iphone")).to eq("ab535538-dc2e-4410-8b40-50fcc852f8bd")
    end
  end

  context "Given no template could be derived" do
    it "returns the generic help response" do
      expect(template_for_message("any unmatched content")).to eq("18859b96-297f-47dd-a579-4e543a83eaa8")
    end
  end
end
