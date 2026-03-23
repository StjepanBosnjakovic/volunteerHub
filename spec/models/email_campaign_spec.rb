require "rails_helper"

RSpec.describe EmailCampaign, type: :model do
  let(:organisation) { create(:organisation) }
  let(:sender)       { create(:user, :coordinator, organisation: organisation) }

  describe "associations" do
    subject { build(:email_campaign, organisation: organisation, sender: sender) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to belong_to(:sender).class_name("User") }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(draft: 0, sending: 1, sent: 2, cancelled: 3)
    }
  end

  describe "validations" do
    subject { build(:email_campaign, organisation: organisation, sender: sender) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:subject_a) }
    it { is_expected.to validate_presence_of(:body_html) }
    it { is_expected.to validate_presence_of(:channel) }
  end

  describe "#ab_test?" do
    it "returns false when no subject_b" do
      campaign = build(:email_campaign, organisation: organisation, sender: sender, subject_b: nil)
      expect(campaign.ab_test?).to be false
    end

    it "returns true when subject_b is present" do
      campaign = build(:email_campaign, :ab_test, organisation: organisation, sender: sender)
      expect(campaign.ab_test?).to be true
    end
  end

  describe "#open_rate_a" do
    it "returns 0 when no recipients" do
      campaign = build(:email_campaign, organisation: organisation, sender: sender, recipient_count: 0)
      expect(campaign.open_rate_a).to eq(0)
    end

    it "calculates percentage correctly" do
      campaign = build(:email_campaign,
        organisation:    organisation,
        sender:          sender,
        recipient_count: 100,
        open_count_a:    25
      )
      expect(campaign.open_rate_a).to eq(25.0)
    end
  end

  describe "#segment_summary" do
    it "returns 'All volunteers' with no filters" do
      campaign = build(:email_campaign, organisation: organisation, sender: sender, segment_filters: {})
      expect(campaign.segment_summary).to eq("All volunteers")
    end

    it "includes role filter in summary" do
      campaign = build(:email_campaign,
        organisation:    organisation,
        sender:          sender,
        segment_filters: { "role" => "volunteer" }
      )
      expect(campaign.segment_summary).to include("volunteer")
    end
  end
end
