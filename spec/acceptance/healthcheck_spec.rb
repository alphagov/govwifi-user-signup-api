RSpec.describe App do
  describe "visiting /healthcheck" do
    it "responds with 200 to a GET" do
      get "/healthcheck"
      expect(last_response).to be_ok
    end

    it "responds with hello world message" do
      get "/healthcheck"
      expect(last_response.body).to eq("Healthy")
    end
  end
end
