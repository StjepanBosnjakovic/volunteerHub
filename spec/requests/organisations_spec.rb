require 'rails_helper'

RSpec.describe "Organisations", type: :request do
  describe "GET /organisation" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      get "/organisation"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organisation/edit" do
    it "returns http success" do
      user = create(:user, :super_admin)
      sign_in user
      get "/organisation/edit"
      expect(response).to have_http_status(:success)
    end
  end
end
