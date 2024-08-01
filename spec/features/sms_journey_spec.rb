describe App do
  describe "/user-signup/sms-notification/notify" do
    include_context "fake notify"
    let(:templates) do
      [
        instance_double(Notifications::Client::Template, name: "credentials_sms", id: "credentials_sms_id"),
      ]
    end
    describe "Signing up to GovWifi via the text message service" do
      let(:from_phone_number) { "07700900000" }
      let(:to_phone_number) { "" }
      let(:message) { "Go" }
      let(:internationalised_phone_number) { "+447700900000" }
      let(:notify_token) { ENV["GOVNOTIFY_BEARER_TOKEN"] }
      let(:created_user) { WifiUser::User.find(contact: internationalised_phone_number) }

      let(:payload) do
        {
          source_number: from_phone_number,
          destination_number: to_phone_number,
          message:,
        }.to_json
      end

      it "sends an SMS containing login details back to the user" do
        post "/user-signup/sms-notification/notify",
             payload,
             "HTTP_AUTHORIZATION" => "Bearer #{notify_token}"

        expect(Services.notify_client).to have_received(:send_sms).with(
          phone_number: internationalised_phone_number,
          template_id: "credentials_sms_id",
          personalisation: {
            login: created_user.username,
            pass: created_user.password,
          },
        )
      end

      context "with a a phone texting itself" do
        shared_examples "rejecting an SMS" do
          before do
            post "/user-signup/sms-notification/notify",
                 payload,
                 "HTTP_AUTHORIZATION" => "Bearer #{notify_token}"
          end

          it "gives an empty ok" do
            expect(last_response.ok?).to be true
            expect(last_response.body).to eq("")
          end

          it "does not send an SMS" do
            expect(Services.notify_client).to_not have_received(:send_sms)
          end
        end

        context "with both the same number" do
          numbers = %w[07900000001 447900000001 +447900000001].freeze
          numbers.each do |from_number|
            numbers.each do |to_number|
              context "with #{from_number} to #{to_number}" do
                let(:from_phone_number) { from_number }
                let(:to_phone_number) { to_number }

                it_behaves_like "rejecting an SMS"
              end
            end
          end
        end
      end

      context "with an invalid bearer token" do
        let(:notify_token) { "INVALID TOKEN" }

        before do
          post "/user-signup/sms-notification/notify",
               { source_number: from_phone_number, message: "Go", destination_number: "" },
               "HTTP_AUTHORIZATION" => "Bearer #{notify_token}"
        end

        it "receives an unauthorised response" do
          expect(last_response.status).to eq(401)
        end

        it "does not send an SMS" do
          expect(Services.notify_client).to_not have_received(:send_sms)
        end
      end
    end
  end
end
