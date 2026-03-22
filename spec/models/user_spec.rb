require 'rails_helper'

RSpec.describe User, type: :model do
  let(:organisation) { create(:organisation) }
  subject { build(:user, organisation: organisation) }

  describe "associations" do
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to have_one(:volunteer_profile).dependent(:destroy) }
    it { is_expected.to have_many(:coordinator_programs).dependent(:destroy) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:role)
        .with_values(super_admin: 0, coordinator: 1, read_only_staff: 2, volunteer: 3)
        .with_prefix
    }
  end

  describe "#admin?" do
    it "returns true for super_admin" do
      user = build(:user, :super_admin, organisation: organisation)
      expect(user.admin?).to be true
    end

    it "returns true for coordinator" do
      user = build(:user, :coordinator, organisation: organisation)
      expect(user.admin?).to be true
    end

    it "returns false for volunteer" do
      user = build(:user, :volunteer, organisation: organisation)
      expect(user.admin?).to be false
    end
  end

  describe "#display_name" do
    it "returns email when no volunteer profile" do
      user = build(:user, email: "test@example.com", organisation: organisation)
      expect(user.display_name).to eq("test@example.com")
    end
  end
end
