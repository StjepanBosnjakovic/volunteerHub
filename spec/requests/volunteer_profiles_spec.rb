require 'rails_helper'

RSpec.describe "VolunteerProfiles", type: :request do
  describe "GET /volunteer_profiles" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      get "/volunteer_profiles"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /volunteer_profiles/:id" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      profile = create(:volunteer_profile, organisation: user.organisation, user: user)
      get "/volunteer_profiles/#{profile.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /volunteer_profiles/new" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      get "/volunteer_profiles/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /volunteer_profiles/:id/edit" do
    it "returns http success" do
      user = create(:user, :coordinator)
      sign_in user
      profile = create(:volunteer_profile, organisation: user.organisation, user: user)
      get "/volunteer_profiles/#{profile.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end
end
