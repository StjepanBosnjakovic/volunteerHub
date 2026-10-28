require 'rails_helper'

RSpec.describe "Metrics", type: :request do
  describe "GET /metrics" do
    around do |example|
      original = ENV["METRICS_TOKEN"]
      ENV["METRICS_TOKEN"] = "secret-token"
      example.run
    ensure
      ENV["METRICS_TOKEN"] = original
    end

    it "returns metrics with a valid token" do
      create(:user, :coordinator)
      get "/metrics", headers: { "Authorization" => "Bearer secret-token" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("volunteerhub_organisations 1")
      expect(response.body).to include('volunteerhub_users{role="coordinator"} 1')
      expect(response.body).to include("volunteerhub_sidekiq_enqueued")
    end

    it "returns not found with a wrong token" do
      get "/metrics", headers: { "Authorization" => "Bearer wrong" }
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found when no token is configured" do
      ENV["METRICS_TOKEN"] = nil
      get "/metrics"
      expect(response).to have_http_status(:not_found)
    end
  end
end
