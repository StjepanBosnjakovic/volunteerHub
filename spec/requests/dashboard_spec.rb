require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end

    it "redirects to the setup wizard when the organisation is not set up" do
      user = create(:user, :coordinator, organisation: create(:organisation, :not_set_up))
      sign_in user
      get "/dashboard"
      expect(response).to redirect_to(setup_details_path)
    end
  end
end
