describe WifiUser::UseCase::SponsorUsers do
  let(:notify_email_url) { "https://api.notifications.service.gov.uk/v2/notifications/email" }
  let(:notify_sms_url) { "https://api.notifications.service.gov.uk/v2/notifications/sms" }
  let(:username) { "dummy_username" }
  let(:password) { "dummy_password" }
  let(:environment) { "production" }
  let(:production_do_not_reply_id) { "0d22d71f-afa3-4c72-8cd4-7716678dbd43" }
  let(:staging_do_not_reply_id) { "45d6b6c4-6a36-47df-b34d-256b8c0d1511" }

  let(:user_model) { double(generate: { username: username, password: password }) }
  let(:whitelist_checker) { double(execute: { success: true }) }
  let(:send_sms_gateway) { double(execute: double(success: true)) }
  let(:send_email_gateway) { double(execute: double(success: true)) }

  subject do
    described_class.new(
      user_model: user_model,
      whitelist_checker: whitelist_checker,
      send_sms_gateway: send_sms_gateway,
      send_email_gateway: send_email_gateway,
    )
  end

  before do
    ENV["RACK_ENV"] = environment
    subject.execute(sponsees, sponsor)
  end

  context "Sponsoring a single email address" do
    let(:sponsor) { "Chris <chris@gov.uk>" }
    let(:sponsees) { ["adrian@example.com<mailto: adrian@example.com>"] }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it "Calls user_model#generate with the sponsees email" do
      expect(user_model).to have_received(:generate) \
        .with(contact: "adrian@example.com", sponsor: "chris@gov.uk")
    end

    it "Sends an email to the sponsee_address with the login details" do
      expect(send_email_gateway).to have_received(:execute)
        .with(a_signup_email(email: "adrian@example.com"))
    end

    it "Sends a single user confirmation email to the sponsor" do
      expect(send_email_gateway).to have_received(:execute)
        .with(
          email_address: "chris@gov.uk",
          template_id: "30ab6bc5-20bf-45af-b78d-34cacc0027cd",
          template_parameters: {
            contact: "adrian@example.com",
          },
          reply_to_id: do_not_reply_id,
        )
    end
  end

  context "Sponsoring a single phone number" do
    let(:sponsor) { "Craig <craig@gov.uk>" }
    let(:sponsees) { ["+44 7700 900003"] }

    it "Calls user_model#generate with the sponsees phone number" do
      expect(user_model).to have_received(:generate) \
        .with(contact: "+447700900003", sponsor: "craig@gov.uk")
    end

    it "Sends an sms to the sponsee_address confirming the signup" do
      expect(send_sms_gateway).to have_received(:execute)
        .with(a_signup_sms(phone_number: "+447700900003"))
    end
  end

  context "Sponsoring the same phone number twice" do
    let(:sponsor) { "Craig <craig@gov.uk>" }
    let(:sponsees) { ["+447700900003", "+447700900003"] }

    it "Calls user_model#generate once" do
      expect(user_model).to have_received(:generate) \
        .with(contact: "+447700900003", sponsor: "craig@gov.uk").once
    end
  end

  context "Sponsoring an email address and a phone number" do
    let(:sponsor) { "Chloe <chloe@gov.uk>" }
    let(:sponsees) { ["Steve <steve@example.com>", "07700900004"] }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it "Calls user_model#generate for the email address" do
      expect(user_model).to have_received(:generate) \
        .with(contact: "steve@example.com", sponsor: "chloe@gov.uk")
    end

    it "Calls the user_model#generate for the phone number" do
      expect(user_model).to have_received(:generate) \
        .with(contact: "+447700900004", sponsor: "chloe@gov.uk")
    end

    it "Sends an email to the sponsee_address with the login details" do
      expect(send_email_gateway).to have_received(:execute)
        .with(a_signup_email(email: "steve@example.com"))
    end

    it "Sends a sms to the sponsee_address confirming the signup" do
      expect(send_sms_gateway).to have_received(:execute)
        .with(a_signup_sms(phone_number: "+447700900004"))
    end

    context "On production" do
      let(:environment) { "production" }
      let(:plural_sponsor_confirmation_template_id) { "58e8ef4a-ca6b-40cd-81df-ec9c781fed56" }

      it "Sends a multiple user confirmation email to the sponsor" do
        expect(send_email_gateway).to have_received(:execute)
          .with(a_plural_sponsor_confirmation)
      end
    end

    context "On staging" do
      let(:environment) { "staging" }
      let(:plural_sponsor_confirmation_template_id) { "856a5726-1099-4236-b67c-23b654e9edbf" }
      let(:do_not_reply_id) { staging_do_not_reply_id }

      it "Sends a multiple user confirmation email to the sponsor" do
        expect(send_email_gateway).to have_received(:execute)
          .with(a_plural_sponsor_confirmation)
      end
    end

    def a_plural_sponsor_confirmation
      {
        email_address: "chloe@gov.uk",
        template_id: plural_sponsor_confirmation_template_id,
        template_parameters: {
          number_of_accounts: 2,
          contacts: "steve@example.com\r\n+447700900004",
        },
        reply_to_id: do_not_reply_id,
      }
    end
  end

  context "Sponsoring invalid contact details" do
    let(:sponsor) { "Cassandra <cassandra@gov.uk>" }
    let(:sponsees) { %w[Peter Paul 07invalid700900004] }
    let(:do_not_reply_id) { production_do_not_reply_id }

    it "Does not call user_model#generate" do
      expect(user_model).not_to have_received(:generate)
    end

    it "sends a sponsorship failed email to the sponsor" do
      expect(send_email_gateway).to have_received(:execute)
        .with(
          email_address: "cassandra@gov.uk",
          template_id: "52c19b68-4d8b-497a-b6ae-ee27d49439c3",
          template_parameters: {
            failedSponsees: "",
          },
          reply_to_id: do_not_reply_id,
        )
    end
  end

  context "Sponsoring from a non-gov email address" do
    let(:sponsor) { "adrian <adrian@fake.uk>" }
    let(:sponsees) { ["adrian@notgov.uk"] }
    let(:do_not_reply_id) { staging_do_not_reply_id }
    let(:whitelist_checker) { double(execute: { success: false }) }

    it "Does not call user_model#generate" do
      expect(user_model).not_to have_received(:generate)
    end
  end

  context "on failing to send to sponsees" do
    let(:sponsor) { "Cassandra <cassandra@gov.uk>" }
    let(:success_sponsees) { [] }
    let(:failed_sponsees) { %w[+447770000666 hello@example.org] }
    let(:sponsees) { success_sponsees + failed_sponsees }
    let(:do_not_reply_id) { production_do_not_reply_id }
    let(:formatted_failed_sponsees) { "* +447770000666\n* hello@example.org" }

    let(:send_sms_gateway) do
      set_send_sms_gateway_execution_branches(
        double,
        successful_numbers: success_sponsees,
        unsucessful_numbers: failed_sponsees,
      )
    end

    let(:send_email_gateway) do
      set_send_email_gateway_execution_branches(
        double,
        successful_emails: success_sponsees,
        unsucessful_emails: failed_sponsees,
      )
    end

    def set_send_sms_gateway_execution_branches(dbl, successful_numbers:, unsucessful_numbers:)
      allow(dbl).to receive(:execute).and_return(double(success: true))
      successful_numbers.each do |sponsee|
        allow(dbl).to receive(:execute)
          .with(hash_including(phone_number: sponsee))
          .and_return(double(success: true))
      end
      unsucessful_numbers.each do |sponsee|
        allow(dbl).to receive(:execute)
          .with(hash_including(phone_number: sponsee))
          .and_return(double(success: false))
      end
      dbl
    end

    def set_send_email_gateway_execution_branches(dbl, successful_emails:, unsucessful_emails:)
      allow(dbl).to receive(:execute).and_return(double(success: true))
      successful_emails.each do |sponsee|
        allow(dbl).to receive(:execute)
          .with(hash_including(email_address: sponsee))
          .and_return(double(success: true))
      end
      unsucessful_emails.each do |sponsee|
        allow(dbl).to receive(:execute)
          .with(hash_including(email_address: sponsee))
          .and_return(double(success: false))
      end
      dbl
    end

    let(:failing_body) do
      {
        email_address: "cassandra@gov.uk",
        template_id: "52c19b68-4d8b-497a-b6ae-ee27d49439c3",
        reply_to_id: do_not_reply_id,
        template_parameters: {
          failedSponsees: formatted_failed_sponsees,
        },
      }
    end

    it "sends a sponsorship failed email to the sponsor" do
      expect(send_email_gateway).to have_received(:execute).with(failing_body)
    end

    context "With one success and one fail" do
      let(:success_sponsees) { %w[+447770000111 one@example.org] }
      let(:failed_sponsees) { %w[+447770000222 two@example.org] }
      let(:formatted_failed_sponsees) { "* +447770000222\n* two@example.org" }

      it "sends a sponsorship failed email to the sponsor" do
        expect(send_email_gateway).to have_received(:execute).with(failing_body)
      end
    end

    context "With one success and two fail" do
      let(:success_sponsees) { %w[+447770000111] }
      let(:failed_sponsees) { %w[+447770000222 +447770000333 one@example.org two@example.org] }
      let(:formatted_failed_sponsees) { "* +447770000222\n* +447770000333\n* one@example.org\n* two@example.org" }

      it "sends a sponsorship failed email to the sponsor" do
        expect(send_email_gateway).to have_received(:execute).with(failing_body)
      end
    end

    context "With two success and one fail" do
      let(:success_sponsees) { %w[+447770000111 +447770000444 three@example.org four@example.org] }
      let(:failed_sponsees) { %w[+447770000222 +447770000333 five@example.org six@example.org] }
      let(:formatted_failed_sponsees) { "* +447770000222\n* +447770000333\n* five@example.org\n* six@example.org" }

      it "sends a sponsorship failed email to the sponsor" do
        expect(send_email_gateway).to have_received(:execute).with(failing_body)
      end
    end
  end

  def a_signup_sms(phone_number:)
    {
      phone_number: phone_number,
      template_id: "3a4b1ca8-7b26-4266-8b5f-e05fdbd11879",
      template_parameters: {
        login: username,
        pass: password,
      },
    }
  end

  def a_signup_email(email:)
    {
      email_address: email,
      template_id: "fd536b81-bdd7-4b55-98aa-720173718642",
      template_parameters: {
        username: username,
        password: password,
        sponsor: sponsor,
      },
      reply_to_id: do_not_reply_id,
    }
  end
end
