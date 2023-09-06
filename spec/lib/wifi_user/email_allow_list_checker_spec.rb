describe WifiUser::EmailAllowListChecker do
  include_context "simple allow list"

  let(:object_to_test) { Class.new { extend WifiUser::EmailAllowListChecker } }

  it "is a valid email" do
    expect(object_to_test.valid_email?("test@gov.uk")).to be true
  end
  it "ignores capitalisation" do
    expect(object_to_test.valid_email?("TeSt@GoV.Uk")).to be true
  end
  it "is a not valid email" do
    expect(object_to_test.valid_email?("test@nongov.uk")).to be false
  end
end
