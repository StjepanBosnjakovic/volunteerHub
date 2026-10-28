require 'rails_helper'

RSpec.describe "Auth pages", type: :request do
  it "renders the sign in page in the app design" do
    get "/users/sign_in"
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Sign in to your account", "Run every shift", "Create one")
  end

  it "shows the alert on the sign in page after a failed sign in" do
    post "/users/sign_in", params: { user: { email: "nobody@example.com", password: "wrong" } }
    expect(response.body).to include("Invalid")
  end

  it "renders the sign up page in the app design" do
    get "/users/sign_up"
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Create your account", "Organisation name", "Run every shift")
  end
end
