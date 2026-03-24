require "rails_helper"

RSpec.describe Testimonial, type: :model do
  let(:organisation)     { create(:organisation) }
  let(:volunteer_profile) { create(:volunteer_profile, organisation: organisation) }

  describe "associations" do
    subject { build(:testimonial, volunteer_profile: volunteer_profile, organisation: organisation) }
    it { is_expected.to belong_to(:volunteer_profile) }
    it { is_expected.to belong_to(:organisation) }
  end

  describe "validations" do
    subject { build(:testimonial, volunteer_profile: volunteer_profile, organisation: organisation) }
    it { is_expected.to validate_presence_of(:quote) }
    it { is_expected.to validate_presence_of(:volunteer_profile) }
    it { is_expected.to validate_presence_of(:organisation) }
  end

  describe "#publish!" do
    it "sets published to true and records published_at" do
      ActsAsTenant.with_tenant(organisation) do
        testimonial = create(:testimonial, volunteer_profile: volunteer_profile, organisation: organisation)
        testimonial.publish!
        expect(testimonial.reload.published).to be true
        expect(testimonial.published_at).to be_within(2.seconds).of(Time.current)
      end
    end
  end

  describe "#unpublish!" do
    it "sets published to false and clears published_at" do
      ActsAsTenant.with_tenant(organisation) do
        testimonial = create(:testimonial, :published, volunteer_profile: volunteer_profile, organisation: organisation)
        testimonial.unpublish!
        expect(testimonial.reload.published).to be false
        expect(testimonial.published_at).to be_nil
      end
    end
  end

  describe "scopes" do
    it ".published returns only published testimonials" do
      ActsAsTenant.with_tenant(organisation) do
        pub   = create(:testimonial, :published, volunteer_profile: volunteer_profile, organisation: organisation)
        draft = create(:testimonial, volunteer_profile: volunteer_profile, organisation: organisation)
        expect(Testimonial.published).to include(pub)
        expect(Testimonial.published).not_to include(draft)
      end
    end
  end
end
