require "rails_helper"

RSpec.describe Message, type: :model do
  let(:organisation) { create(:organisation) }
  let(:user)         { create(:user, organisation: organisation) }
  let(:conversation) { create(:conversation, organisation: organisation) }

  describe "associations" do
    subject { build(:message, conversation: conversation, sender: user) }
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:sender).class_name("User") }
    it { is_expected.to have_many(:message_reads).dependent(:destroy) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:message_type).with_values(text: 0, system: 1) }
  end

  describe "validations" do
    subject { build(:message, conversation: conversation, sender: user) }
    it { is_expected.to validate_presence_of(:conversation) }
    it { is_expected.to validate_presence_of(:sender) }
  end

  describe "#read_by?" do
    it "returns false when not read" do
      ActsAsTenant.with_tenant(organisation) do
        msg = create(:message, conversation: conversation, sender: user)
        other = create(:user, organisation: organisation)
        expect(msg.read_by?(other)).to be false
      end
    end

    it "returns true after mark_read_by!" do
      ActsAsTenant.with_tenant(organisation) do
        msg = create(:message, conversation: conversation, sender: user)
        other = create(:user, organisation: organisation)
        msg.mark_read_by!(other)
        expect(msg.read_by?(other)).to be true
      end
    end
  end

  describe "scopes" do
    it ".ordered returns messages in ascending creation order" do
      ActsAsTenant.with_tenant(organisation) do
        m1 = create(:message, conversation: conversation, sender: user, created_at: 2.hours.ago)
        m2 = create(:message, conversation: conversation, sender: user, created_at: 1.hour.ago)
        expect(Message.ordered.to_a).to eq([m1, m2])
      end
    end
  end
end
