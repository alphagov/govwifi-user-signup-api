describe WifiUser::UseCase::ContactSanitiser do
  it "strips off mailto in angle brackets" do
    email = "emile@gov.uk<mailto:emile@gov.uk>"
    expect(subject.execute(email)).to eq("emile@gov.uk")
  end

  it "strips off appending text" do
    email = "adrian@gov.uk Adrian"
    expect(subject.execute(email)).to eq("adrian@gov.uk")
  end

  it "strips off preceding text" do
    email = "Chris <chris@gov.uk>"
    expect(subject.execute(email)).to eq("chris@gov.uk")
  end

  it "internationalises a phone number" do
    phone_number = "07700900004"
    expect(subject.execute(phone_number)).to eq("+447700900004")
  end

  it "strips spaces from a phone number" do
    phone_number = "07700 900 004"
    expect(subject.execute(phone_number)).to eq("+447700900004")
  end

  it "passes through an internationalised phone number" do
    phone_number = "+447700900004"
    expect(subject.execute(phone_number)).to eq("+447700900004")
  end

  it "does not throw an exception when given crap" do
    expect(subject.execute("asdoihoasdhsioadhj")).to eq(nil)
  end

  it "does not throw an exception when given a named number" do
    expect(subject.execute("ABCDELIVERY")).to eq(nil)
  end
end
