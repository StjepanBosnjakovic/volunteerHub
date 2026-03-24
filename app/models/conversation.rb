class Conversation < ApplicationRecord
  acts_as_tenant :organisation

  enum :conversation_type, { direct: 0, group_chat: 1 }

  belongs_to :organisation
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy

  validates :conversation_type, presence: true
  validates :title, presence: true, if: :group_chat?

  scope :ordered, -> { order(updated_at: :desc) }
  scope :for_user, ->(user) {
    joins(:conversation_participants)
      .where(conversation_participants: { user_id: user.id })
  }

  def display_title(current_user)
    return title if group_chat?

    other = participants.where.not(id: current_user.id).first
    other&.display_name || "Direct Message"
  end

  def unread_count_for(user)
    participant = conversation_participants.find_by(user_id: user.id)
    return 0 unless participant

    last_read = participant.last_read_at
    return messages.count unless last_read

    messages.where("created_at > ?", last_read).count
  end

  def mark_read_for!(user)
    conversation_participants.find_by(user_id: user.id)
                             &.update!(last_read_at: Time.current)
  end

  def self.find_or_create_direct(user_a, user_b, organisation)
    ActsAsTenant.with_tenant(organisation) do
      existing = joins(:conversation_participants)
        .where(conversation_type: :direct)
        .where(conversation_participants: { user_id: user_a.id })
        .joins("INNER JOIN conversation_participants cp2 ON cp2.conversation_id = conversations.id AND cp2.user_id = #{user_b.id}")
        .first

      return existing if existing

      transaction do
        conv = create!(conversation_type: :direct, organisation: organisation)
        conv.conversation_participants.create!(user: user_a)
        conv.conversation_participants.create!(user: user_b)
        conv
      end
    end
  end
end
