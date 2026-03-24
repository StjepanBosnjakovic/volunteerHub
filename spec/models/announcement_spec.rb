require "rails_helper"

RSpec.describe Announcement, type: :model do
  let(:organisation) { create(:organisation) }
  let(:author)       { create(:user, organisation: organisation) }

  before { allow_any_instance_of(Announcement).to receive(:broadcast_feed_update) }

  describe "associations" do
    subject { build(:announcement, organisation: organisation, author: author) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to belong_to(:author).class_name("User") }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(draft: 0, published: 1, scheduled: 2, archived: 3)
    }
  end

  describe "validations" do
    subject { build(:announcement, organisation: organisation, author: author) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
  end

  describe "#publish!" do
    it "sets status to published and published_at to now" do
      ActsAsTenant.with_tenant(organisation) do
        announcement = create(:announcement, organisation: organisation, author: author)
        announcement.publish!
        expect(announcement.reload.status).to eq("published")
        expect(announcement.published_at).to be_within(2.seconds).of(Time.current)
      end
    end
  end

  describe "#schedule!" do
    it "sets status to scheduled and scheduled_for" do
      ActsAsTenant.with_tenant(organisation) do
        announcement = create(:announcement, organisation: organisation, author: author)
        future = 2.days.from_now
        announcement.schedule!(at: future)
        expect(announcement.reload.status).to eq("scheduled")
        expect(announcement.scheduled_for).to be_within(1.second).of(future)
      end
    end
  end

  describe "scopes" do
    it ".visible returns only published past announcements" do
      ActsAsTenant.with_tenant(organisation) do
        visible   = create(:announcement, :published, organisation: organisation, author: author)
        draft     = create(:announcement, organisation: organisation, author: author)
        scheduled = create(:announcement, :scheduled, organisation: organisation, author: author)

        expect(Announcement.visible).to include(visible)
        expect(Announcement.visible).not_to include(draft, scheduled)
      end
    end
  end
end
