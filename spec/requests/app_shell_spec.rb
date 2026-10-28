require 'rails_helper'

RSpec.describe "App shell screens", type: :request do
  let(:user) { create(:user, :coordinator) }
  let(:organisation) { user.organisation }

  before { sign_in user }

  it "renders the sidebar navigation on the dashboard" do
    get "/dashboard"
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Shifts needing volunteers", "Recent sign-ups", "Broadcasts")
  end

  it "filters shifts by fill status" do
    program = ActsAsTenant.with_tenant(organisation) { Program.create!(name: "Events", organisation: organisation) }
    volunteer = create(:volunteer_profile, organisation: organisation, user: create(:user, organisation: organisation))
    full = program.shifts.create!(title: "Full shift", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, capacity: 1)
    program.shifts.create!(title: "Open shift", starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, capacity: 3)
    ShiftAssignment.create!(shift: full, volunteer_profile: volunteer, status: :confirmed)

    get "/programs/#{program.id}/shifts", params: { fill: "needs" }
    expect(response.body).to include("Open shift")
    expect(response.body).not_to include("Full shift")

    get "/programs/#{program.id}/shifts", params: { fill: "filled" }
    expect(response.body).to include("Full shift")
    expect(response.body).not_to include("Open shift")
  end

  it "searches volunteers and shows the selected profile drawer" do
    match = create(:volunteer_profile, organisation: organisation, first_name: "Zelda", last_name: "Quill",
                   user: create(:user, organisation: organisation))
    create(:volunteer_profile, organisation: organisation, first_name: "Other", last_name: "Person",
           user: create(:user, organisation: organisation))

    get "/volunteer_profiles", params: { q: "zelda q" }
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Zelda Quill")
    expect(response.body).not_to include("Other Person")

    get "/volunteer_profiles", params: { selected: match.id }
    expect(response.body).to include("Upcoming shifts")
  end

  it "renders the hours, messages, broadcasts and opportunities screens" do
    %w[/hour_logs /conversations /broadcast_messages /opportunities].each do |path|
      get path
      expect(response).to have_http_status(:success), "expected #{path} to render"
    end
  end

  it "renders a conversation next to the inbox" do
    other = create(:user, organisation: organisation)
    conversation = Conversation.find_or_create_direct(user, other, organisation)

    get "/conversations/#{conversation.id}"
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Inbox")
  end
end
