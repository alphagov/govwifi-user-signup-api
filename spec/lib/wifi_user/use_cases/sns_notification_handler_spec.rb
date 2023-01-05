describe WifiUser::UseCase::SnsNotificationHandler do
  let(:payload) do
    { type: notification_type,
      message_id:,
      to_address:,
      from_address: "sally@something.gov.uk",
      s3_object_key: "some-s3-object-key",
      s3_bucket_name: "some-s3-bucket-name" }
  end
  let(:message_id) { "some-message-id" }
  let(:to_address) { "bob@something.gov.uk" }
  let(:email_signup_handler) { double(execute: nil) }
  let(:sponsor_signup_handler) { double(execute: nil) }
  let(:logger) { double(debug: nil) }
  let(:notification_type) { "Notification" }

  subject do
    described_class.new(
      email_signup_handler:,
      sponsor_signup_handler:,
      logger:,
    )
  end

  before do
    allow_any_instance_of(Common::Gateway::S3ObjectFetcher).to receive(:fetch) # This will go away once injected
  end

  context "Given a Notification request" do
    before do
      subject.handle(payload)
    end
    context "Given it is a signup request" do
      it "executes the signup handler" do
        expect(email_signup_handler).to have_received(:execute).with(contact: "sally@something.gov.uk")
      end
    end

    context "Given it is a sponsor request" do
      let(:to_address) { "sponsor@something.gov.uk" }

      it "logs the request" do
        expect(logger).to have_received(:debug)
      end

      it "executes the sponsor handler" do
        empty_sponsors = []
        expect(sponsor_signup_handler).to have_received(:execute).with(empty_sponsors, "sally@something.gov.uk")
      end
    end
  end

  context "Given a non-Notification request" do
    let(:notification_type) { "some-other-type" }

    it "does not process the request" do
      expect(email_signup_handler).to_not have_received(:execute)
    end
  end
end
