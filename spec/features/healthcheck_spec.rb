require_relative "./shared"

RSpec.describe App do
  include_context "fake notify"

  let(:templates) do
    Notifications::NotifyTemplates::TEMPLATES.map do |name|
      instance_double(Notifications::Client::Template, name:, id: "#{name}_id")
    end
  end
  describe "GET /healthcheck" do
    it "is healthy" do
      get "/healthcheck"
      expect(last_response.body).to eq("Healthy")
      expect(last_response).to be_successful
    end
    it "is not healthy because a template is missing" do
      missing_template = templates.delete_at(0)
      get "/healthcheck"
      expect(last_response.body).to eq("Some templates have not been defined in Notify: #{missing_template.name}")
      expect(last_response.status).to eq(500)
    end
  end
end
