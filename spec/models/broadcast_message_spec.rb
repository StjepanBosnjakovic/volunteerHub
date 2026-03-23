require "rails_helper"

RSpec.describe BroadcastMessage, type: :model do
  let(:organisation) { create(:organisation) }
  let(:sender)       { create(:user, :coordinator, organisation: organisation) }

  describe "associations" do
    subject { build(:broadcast_message, organisation: organisation, sender: sender) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to belong_to(:sender).class_name("User") }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:channel)
        .with_values(in_app: 0, email: 1, sms: 2, whatsapp: 3)
    }
    it {
      is_expected.to define_enum_for(:status)
        .with_values(draft: 0, sending: 1, sent: 2, failed: 3)
    }
  end

  describe "validations" do
    subject { build(:broadcast_message, organisation: organisation, sender: sender) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:channel) }
  end

  describe "#resolve_recipients" do
    it "returns all org volunteers with no filters" do
      ActsAsTenant.with_tenant(organisation) do
        create(:user, :volunteer, organisation: organisation)
        create(:user, :volunteer, organisation: organisation)
        broadcast = create(:broadcast_message, organisation: organisation, sender: sender)
        expect(broadcast.resolve_recipients.count).to be >= 2
      end
    end

    it "filters by role when role filter is set" do
      ActsAsTenant.with_tenant(organisation) do
        create(:user, :volunteer,    organisation: organisation)
        create(:user, :coordinator,  organisation: organisation)
        broadcast = create(:broadcast_message,
          organisation:    organisation,
          sender:          sender,
          segment_filters: { "role" => "volunteer" }
        )
        results = broadcast.resolve_recipients
        expect(results.all? { |u| u.role_volunteer? }).to be true
      end
    end
  end

  describe "scopes" do
    it ".ordered returns most recent first" do
      ActsAsTenant.with_tenant(organisation) do
        older = create(:broadcast_message, organisation: organisation, sender: sender, created_at: 2.hours.ago)
        newer = create(:broadcast_message, organisation: organisation, sender: sender, created_at: 1.hour.ago)
        expect(BroadcastMessage.ordered.first).to eq(newer)
      end
    end
  end
end
