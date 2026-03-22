require 'rails_helper'

RSpec.describe "VolunteerProfiles", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/volunteer_profiles/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/volunteer_profiles/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/volunteer_profiles/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/volunteer_profiles/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
