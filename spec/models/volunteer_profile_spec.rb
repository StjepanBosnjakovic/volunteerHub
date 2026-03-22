require 'rails_helper'

RSpec.describe VolunteerProfile, type: :model do
  let(:organisation) { create(:organisation) }
  subject do
    ActsAsTenant.with_tenant(organisation) do
      build(:volunteer_profile, organisation: organisation)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to have_many(:volunteer_skills).dependent(:destroy) }
    it { is_expected.to have_many(:skills).through(:volunteer_skills) }
    it { is_expected.to have_many(:availabilities).dependent(:destroy) }
    it { is_expected.to have_many(:blackout_dates).dependent(:destroy) }
    it { is_expected.to have_many(:emergency_contacts).dependent(:destroy) }
    it { is_expected.to have_many(:credentials).dependent(:destroy) }
  end

  describe "#full_name" do
    it "returns first + last name" do
      profile = build(:volunteer_profile, first_name: "Jane", last_name: "Doe", preferred_name: nil)
      expect(profile.full_name).to eq("Jane Doe")
    end

    it "uses preferred name when set" do
      profile = build(:volunteer_profile, first_name: "Jane", last_name: "Doe", preferred_name: "Janie")
      expect(profile.full_name).to eq("Janie Doe")
    end
  end

  describe "#age" do
    it "calculates age correctly" do
      profile = build(:volunteer_profile, date_of_birth: 25.years.ago.to_date)
      expect(profile.age).to eq(25)
    end

    it "returns nil if no date_of_birth" do
      profile = build(:volunteer_profile, date_of_birth: nil)
      expect(profile.age).to be_nil
    end
  end

  describe "minor safeguarding flag" do
    it "sets is_minor to true when DOB indicates under 18" do
      ActsAsTenant.with_tenant(organisation) do
        user = create(:user, organisation: organisation)
        profile = create(:volunteer_profile, organisation: organisation, user: user, date_of_birth: 16.years.ago.to_date)
        expect(profile.is_minor).to be true
      end
    end

    it "sets is_minor to false when DOB indicates 18 or over" do
      ActsAsTenant.with_tenant(organisation) do
        user = create(:user, organisation: organisation)
        profile = create(:volunteer_profile, organisation: organisation, user: user, date_of_birth: 20.years.ago.to_date)
        expect(profile.is_minor).to be false
      end
    end
  end

  describe "#anonymize!" do
    it "redacts PII fields" do
      ActsAsTenant.with_tenant(organisation) do
        user = create(:user, organisation: organisation)
        profile = create(:volunteer_profile, organisation: organisation, user: user)
        profile.anonymize!
        expect(profile.reload.first_name).to eq("REDACTED")
        expect(profile.last_name).to eq("REDACTED")
        expect(profile.phone).to be_nil
      end
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, active: 1, inactive: 2).with_prefix(:status) }
  end
end
