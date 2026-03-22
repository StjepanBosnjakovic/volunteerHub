require 'rails_helper'

RSpec.describe "Organisations", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/organisations/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/organisations/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
