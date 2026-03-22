require 'rails_helper'

RSpec.describe Organisation, type: :model do
  subject { create(:organisation) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }
    it { is_expected.to have_many(:volunteer_profiles).dependent(:destroy) }
    it { is_expected.to have_many(:skills).dependent(:destroy) }
    it { is_expected.to have_many(:interest_categories).dependent(:destroy) }
    it { is_expected.to have_many(:custom_fields).dependent(:destroy) }
  end

  describe "slug generation" do
    it "auto-generates slug from name" do
      org = build(:organisation, name: "Helping Hands", slug: nil)
      org.valid?
      expect(org.slug).to eq("helping-hands")
    end

    it "does not overwrite an existing slug" do
      org = build(:organisation, name: "Helping Hands", slug: "my-custom-slug")
      org.valid?
      expect(org.slug).to eq("my-custom-slug")
    end
  end
end
