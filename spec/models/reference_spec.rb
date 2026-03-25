require "rails_helper"

RSpec.describe Reference, type: :model do
  let(:organisation)     { create(:organisation) }
  let(:volunteer_profile) { create(:volunteer_profile, organisation: organisation) }
  let(:coordinator)      { create(:user, organisation: organisation) }

  describe "associations" do
    subject { build(:reference, volunteer_profile: volunteer_profile, coordinator: coordinator) }
    it { is_expected.to belong_to(:volunteer_profile) }
    it { is_expected.to belong_to(:coordinator).class_name("User") }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(requested: 0, issued: 1, declined: 2)
    }
  end

  describe "validations" do
    subject { build(:reference, volunteer_profile: volunteer_profile, coordinator: coordinator) }
    it { is_expected.to validate_presence_of(:volunteer_profile) }
    it { is_expected.to validate_presence_of(:coordinator) }
  end

  describe "#issue!" do
    it "sets status to issued and records issued_at" do
      reference = create(:reference, volunteer_profile: volunteer_profile, coordinator: coordinator)
      reference.issue!(coordinator: coordinator)
      reference.reload
      expect(reference).to be_issued
      expect(reference.issued_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
