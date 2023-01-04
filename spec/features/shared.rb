RSpec.shared_examples "sends_template" do |template_id|
  it "sends an sms template" do
    do_user_signup
    expect(Services.notify_client).to have_received(:send_sms).with(hash_including(template_id:))
  end
  it "creates a new user" do
    expect { do_user_signup }.to change(WifiUser::Repository::User, :count).by(1)
  end
end

RSpec.shared_examples "rejects_email" do
  it "Does not create a user" do
    expect {
      post "/user-signup/email-notification", request_body.to_json, email_request_headers
    }.to_not change(WifiUser::Repository::User, :count)
  end
  it "Does not send an email" do
    post "/user-signup/email-notification", request_body.to_json, email_request_headers
    expect(Services.notify_client).to_not have_received(:send_email)
  end
  it "returns 200" do
    post "/user-signup/email-notification", request_body.to_json, email_request_headers
    expect(last_response.body).to eq("")
    expect(last_response).to be_successful
  end
end
