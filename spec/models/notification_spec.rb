require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:organisation) { create(:organisation) }
  let(:user)         { create(:user, organisation: organisation) }

  describe "associations" do
    subject { build(:notification, recipient: user, organisation: organisation) }
    it { is_expected.to belong_to(:recipient).class_name("User") }
    it { is_expected.to belong_to(:organisation) }
  end

  describe "validations" do
    subject { build(:notification, recipient: user, organisation: organisation) }
    it { is_expected.to validate_presence_of(:recipient) }
    it { is_expected.to validate_presence_of(:notification_type) }
  end

  describe "scopes" do
    it ".unread returns only unread notifications" do
      ActsAsTenant.with_tenant(organisation) do
        unread = create(:notification, recipient: user, organisation: organisation)
        read   = create(:notification, :read, recipient: user, organisation: organisation)
        expect(Notification.unread).to include(unread)
        expect(Notification.unread).not_to include(read)
      end
    end

    it ".ordered returns notifications newest first" do
      ActsAsTenant.with_tenant(organisation) do
        older = create(:notification, recipient: user, organisation: organisation, created_at: 2.hours.ago)
        newer = create(:notification, recipient: user, organisation: organisation, created_at: 1.hour.ago)
        expect(Notification.ordered.first).to eq(newer)
      end
    end
  end

  describe "#read!" do
    it "sets read_at" do
      ActsAsTenant.with_tenant(organisation) do
        n = create(:notification, recipient: user, organisation: organisation)
        expect { n.read! }.to change { n.reload.read_at }.from(nil)
      end
    end

    it "is idempotent" do
      ActsAsTenant.with_tenant(organisation) do
        n = create(:notification, :read, recipient: user, organisation: organisation)
        original_read_at = n.read_at
        n.read!
        expect(n.reload.read_at).to eq(original_read_at)
      end
    end
  end

  describe "#unread?" do
    it "returns true when read_at is nil" do
      n = build(:notification, read_at: nil)
      expect(n.unread?).to be true
    end

    it "returns false when read_at is set" do
      n = build(:notification, :read)
      expect(n.unread?).to be false
    end
  end

  describe "TYPES" do
    it "includes key notification types" do
      expect(Notification::TYPES).to include("shift_reminder", "hour_approved", "milestone_reached")
    end
  end
end
