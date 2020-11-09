describe WifiUser::UseCase::SnsNotificationHandler do
  let(:request) { double(body: double(read: {})) }
  let(:email_parser) { double }
  let(:message_id) { "some-message-id" }
  let(:to_address) { "bob@something.gov.uk" }
  let(:email_signup_handler) { double(execute: nil) }
  let(:sponsor_signup_handler) { double(execute: nil) }
  let(:logger) { double(debug: nil) }
  let(:notification_type) { "Notification" }
  let(:sns_type_header_name) { "HTTP_X_AMZ_SNS_MESSAGE_TYPE" }

  subject do
    described_class.new(
      email_signup_handler: email_signup_handler,
      sponsor_signup_handler: sponsor_signup_handler,
      email_parser: email_parser,
      logger: logger,
    )
  end

  before do
    allow(email_parser).to receive(:execute).and_return(
      type: notification_type,
      message_id: message_id,
      to_address: to_address,
      from_address: "sally@something.gov.uk",
      s3_object_key: "some-s3-object-key",
      s3_bucket_name: "some-s3-bucket-name",
    )

    allow_any_instance_of(Common::Gateway::S3ObjectFetcher).to receive(:fetch) # This will go away once injected

    allow(request).to receive(:get_header).with(sns_type_header_name).and_return(notification_type)
    allow(request).to receive(:has_header?).with(sns_type_header_name).and_return(true)
  end

  it "parses the request" do
    subject.handle(request)
    expect(email_parser).to have_received(:execute)
  end

  context "Given a Notification request" do
    before do
      subject.handle(request)
    end
    context "Given a message id that is not AMAZON_SES_SETUP_NOTIFICATION" do
      context "Given it is a signup request" do
        it "logs the request" do
          expect(logger).to have_received(:debug)
        end

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

        context "Given a message id of AMAZON_SES_SETUP_NOTIFICATION" do
          let(:message_id) { "AMAZON_SES_SETUP_NOTIFICATION" }

          it "does not process the request" do
            expect(sponsor_signup_handler).to_not have_received(:execute)
          end
        end
      end
    end
  end

  context "Given a non-Notification request" do
    let(:notification_type) { "some-other-type" }

    it "does not process the request" do
      expect(email_signup_handler).to_not have_received(:execute)
    end
  end

  context "Given an invalid request" do
    before do
      allow(email_parser).to receive(:execute).and_raise(KeyError)
      subject.handle(request)
    end

    it "stops processing the request" do
      expect(email_signup_handler).to_not have_received(:execute)
    end

    it "logs the request" do
      expect(logger).to have_received(:debug).with("Unable to process signup.  Malformed request: {}")
    end
  end
end
