describe Notifications::NotificationRetriever do
  let(:subject) { Notifications::NotificationRetriever }
  let(:url) do
    URI.join(Notifications::Client::PRODUCTION_BASE_URL, "v2/notifications")
  end

  before :each do
    DB[:notifications].truncate
    @db = DB[:notifications]
  end

  it "retrieves a notification and saves it in the database" do
    hash = FactoryBot.build(:notification)

    stub_request(:get, url).with(query: {}).to_return({ status: 200, body: { "notifications": [hash] }.to_json })
    stub_request(:get, url).with(query: { older_than: hash[:id] }).to_return({ status: 200, body: { "notifications": [] }.to_json })
    subject.execute

    expect(@db.all.count).to eq(1)
    expect(@db.first).to include(
      id: hash[:id],
      reference: hash[:reference],
      email_address: hash[:email_address],
      phone_number: hash[:phone_number],
      type: hash[:type],
      template_version: hash[:template]["version"],
      template_id: hash[:template]["id"],
      template_uri: hash[:template]["uri"],
      body: hash[:body],
      subject: hash[:subject],
    )
    expect(@db.first[:created_at]).to be_within(1).of(hash[:created_at])
    expect(@db.first[:sent_at]).to be_within(1).of(hash[:sent_at])
    expect(@db.first[:completed_at]).to be_within(1).of(hash[:completed_at])
  end

  it "Duplicates are updated" do
    sending_hash = FactoryBot.build(:notification, status: "Sending")

    stub_request(:get, url).with(query: {}).to_return({ status: 200, body: { "notifications": [sending_hash] }.to_json })
    stub_request(:get, url).with(query: { older_than: sending_hash[:id] }).to_return({ status: 200, body: { "notifications": [] }.to_json })

    subject.execute
    delivered_hash = sending_hash.merge(status: "Delivered")
    stub_request(:get, url).with(query: {}).to_return({ status: 200, body: { "notifications": [delivered_hash] }.to_json })

    expect { subject.execute }.to change { @db.first[:status] }.from("Sending").to("Delivered")
  end
end
