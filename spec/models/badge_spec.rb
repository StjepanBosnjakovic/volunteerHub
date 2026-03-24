require "rails_helper"

RSpec.describe Badge, type: :model do
  let(:organisation) { create(:organisation) }

  describe "associations" do
    subject { build(:badge, organisation: organisation) }
    it { is_expected.to belong_to(:organisation).optional }
    it { is_expected.to have_many(:volunteer_badges).dependent(:destroy) }
    it { is_expected.to have_many(:volunteer_profiles).through(:volunteer_badges) }
  end

  describe "validations" do
    subject { build(:badge, organisation: organisation) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:criteria_type) }
    it { is_expected.to validate_inclusion_of(:criteria_type).in_array(Badge::CRITERIA_TYPES) }
  end

  describe "scopes" do
    it ".ordered returns badges by name" do
      ActsAsTenant.with_tenant(organisation) do
        b2 = create(:badge, organisation: organisation, name: "Zeal Award")
        b1 = create(:badge, organisation: organisation, name: "Achiever")
        expect(Badge.ordered.first).to eq(b1)
        expect(Badge.ordered.last).to eq(b2)
      end
    end

    it ".system_badges returns badges with no organisation" do
      ActsAsTenant.with_tenant(organisation) do
        system = create(:badge, :system_badge)
        org    = create(:badge, organisation: organisation)
        expect(Badge.system_badges).to include(system)
        expect(Badge.system_badges).not_to include(org)
      end
    end
  end

  describe "#auto_awardable?" do
    it "returns true for non-manual criteria" do
      badge = build(:badge, criteria_type: "hours_reached")
      expect(badge.auto_awardable?).to be true
    end

    it "returns false for manual criteria" do
      badge = build(:badge, :manual)
      expect(badge.auto_awardable?).to be false
    end
  end

  describe "#system_badge?" do
    it "returns true when organisation is nil" do
      badge = build(:badge, :system_badge)
      expect(badge.system_badge?).to be true
    end

    it "returns false when organisation is present" do
      badge = build(:badge, organisation: organisation)
      expect(badge.system_badge?).to be false
    end
  end
end
