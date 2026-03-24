require "rails_helper"

RSpec.describe Conversation, type: :model do
  let(:organisation) { create(:organisation) }
  let(:user_a)       { create(:user, organisation: organisation) }
  let(:user_b)       { create(:user, organisation: organisation) }

  describe "associations" do
    subject { build(:conversation, organisation: organisation) }
    it { is_expected.to belong_to(:organisation) }
    it { is_expected.to have_many(:conversation_participants).dependent(:destroy) }
    it { is_expected.to have_many(:participants).through(:conversation_participants) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:conversation_type).with_values(direct: 0, group_chat: 1) }
  end

  describe "validations" do
    context "group conversation" do
      subject { build(:conversation, :group_chat, organisation: organisation) }
      it { is_expected.to validate_presence_of(:title) }
    end

    context "direct conversation" do
      subject { build(:conversation, organisation: organisation) }
      it { is_expected.to be_valid }
    end
  end

  describe ".find_or_create_direct" do
    it "creates a direct conversation between two users" do
      ActsAsTenant.with_tenant(organisation) do
        conv = described_class.find_or_create_direct(user_a, user_b, organisation)
        expect(conv).to be_persisted
        expect(conv.participants).to include(user_a, user_b)
      end
    end

    it "returns the existing conversation on second call" do
      ActsAsTenant.with_tenant(organisation) do
        conv1 = described_class.find_or_create_direct(user_a, user_b, organisation)
        conv2 = described_class.find_or_create_direct(user_a, user_b, organisation)
        expect(conv1.id).to eq(conv2.id)
      end
    end
  end

  describe "#unread_count_for" do
    it "returns count of messages after last_read_at" do
      ActsAsTenant.with_tenant(organisation) do
        conv = create(:conversation, organisation: organisation)
        conv.conversation_participants.create!(user: user_a)
        conv.conversation_participants.create!(user: user_b)

        create(:message, conversation: conv, sender: user_b)
        expect(conv.unread_count_for(user_a)).to eq(1)

        conv.mark_read_for!(user_a)
        expect(conv.unread_count_for(user_a)).to eq(0)
      end
    end
  end

  describe "#display_title" do
    it "returns the other participant's name for direct conversations" do
      ActsAsTenant.with_tenant(organisation) do
        conv = described_class.find_or_create_direct(user_a, user_b, organisation)
        expect(conv.display_title(user_a)).to eq(user_b.display_name)
      end
    end

    it "returns the title for group conversations" do
      ActsAsTenant.with_tenant(organisation) do
        conv = create(:conversation, :group_chat, organisation: organisation)
        expect(conv.display_title(user_a)).to eq(conv.title)
      end
    end
  end
end
