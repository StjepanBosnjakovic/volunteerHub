require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end
  end
end
