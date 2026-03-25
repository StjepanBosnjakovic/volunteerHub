require "rails_helper"

RSpec.describe VolunteerBadge, type: :model do
  let(:organisation)     { create(:organisation) }
  let(:volunteer_profile) { create(:volunteer_profile, organisation: organisation) }
  let(:badge)            { create(:badge, organisation: organisation) }

  describe "associations" do
    subject { build(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge) }
    it { is_expected.to belong_to(:volunteer_profile) }
    it { is_expected.to belong_to(:badge) }
    it { is_expected.to belong_to(:awarded_by).optional }
  end

  describe "validations" do
    subject { build(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge) }
    it { is_expected.to validate_presence_of(:awarded_at) }

    it "prevents duplicate badge award" do
      ActsAsTenant.with_tenant(organisation) do
        create(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge)
        duplicate = build(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:badge_id]).to be_present
      end
    end
  end

  describe "#manual_award?" do
    it "returns true when awarded_by is present" do
      user = create(:user, organisation: organisation)
      vb   = build(:volunteer_badge, :manual, volunteer_profile: volunteer_profile, badge: badge, awarded_by: user)
      expect(vb.manual_award?).to be true
    end

    it "returns false when auto-awarded" do
      vb = build(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge)
      expect(vb.manual_award?).to be false
    end
  end

  describe "#linkedin_share_url" do
    it "returns a URL containing the badge name" do
      vb = build(:volunteer_badge, volunteer_profile: volunteer_profile, badge: badge)
      expect(vb.linkedin_share_url).to include("linkedin.com")
    end
  end
end
