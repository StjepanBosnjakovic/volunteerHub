require "rails_helper"

RSpec.describe NotificationPreference, type: :model do
  let(:organisation) { create(:organisation) }
  let(:user)         { create(:user, organisation: organisation) }

  describe "associations" do
    subject { build(:notification_preference, user: user) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:notification_preference, user: user) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:notification_type) }

    it "validates notification_type is a known type" do
      pref = build(:notification_preference, user: user, notification_type: "invalid_type")
      expect(pref).not_to be_valid
    end

    it "validates uniqueness of notification_type scoped to user" do
      create(:notification_preference, user: user, notification_type: "shift_reminder")
      duplicate = build(:notification_preference, user: user, notification_type: "shift_reminder")
      expect(duplicate).not_to be_valid
    end
  end

  describe ".defaults_for" do
    it "creates preferences for all notification types" do
      NotificationPreference.defaults_for(user)
      expect(user.notification_preferences.count).to eq(Notification::TYPES.length)
    end

    it "is idempotent" do
      NotificationPreference.defaults_for(user)
      NotificationPreference.defaults_for(user)
      expect(user.notification_preferences.count).to eq(Notification::TYPES.length)
    end
  end
end
