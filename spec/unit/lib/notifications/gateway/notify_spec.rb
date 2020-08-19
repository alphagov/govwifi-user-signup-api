describe Notifications::Gateway::Notify do
  let(:subject) { Notifications::Gateway::Notify }
  let(:url) do
    URI.join(Notifications::Client::PRODUCTION_BASE_URL, "v2/notifications")
  end

  it "returns an empty enum" do
    stub_request(:get, url).with(query: {}).to_return({ status: 200, body: { "notifications": [] }.to_json })
    results = subject.new(ENV["NOTIFY_API_KEY"]).to_enum.to_a
    expect(results).to be_empty
  end

  it "Returns an enum with all available notifications" do
    list1 = FactoryBot.build_list(:notification, 10)
    list2 = FactoryBot.build_list(:notification, 5)
    list3 = []

    stub_request(:get, url).with(query: {}).to_return({ status: 200, body: { "notifications": list1 }.to_json })
    stub_request(:get, url).with(query: { older_than: list1.last[:id] }).to_return({ status: 200, body: { "notifications": list2 }.to_json })
    stub_request(:get, url).with(query: { older_than: list2.last[:id] }).to_return({ status: 200, body: { "notifications": list3 }.to_json })

    results = subject.new(ENV["NOTIFY_API_KEY"]).to_enum.to_a
    expect(results.count).to eq(15)
    expect(results[0..9].map(&:id)).to eq(list1.map { |n| n[:id] })
    expect(results[10..14].map(&:id)).to eq(list2.map { |n| n[:id] })
  end
end
