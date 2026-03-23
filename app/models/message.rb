class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"
  has_many   :message_reads, dependent: :destroy
  has_rich_text :body

  enum :message_type, { text: 0, system: 1 }

  validates :conversation, presence: true
  validates :sender,       presence: true

  scope :ordered, -> { order(created_at: :asc) }
  scope :recent,  -> { order(created_at: :desc) }

  after_create_commit :broadcast_to_conversation
  after_create_commit :touch_conversation

  def read_by?(user)
    message_reads.exists?(user_id: user.id)
  end

  def mark_read_by!(user)
    message_reads.find_or_create_by!(user: user) do |mr|
      mr.read_at = Time.current
    end
  end

  private

  def broadcast_to_conversation
    Turbo::StreamsChannel.broadcast_append_to(
      "conversation_#{conversation_id}",
      target:  "messages",
      partial: "messages/message",
      locals:  { message: self }
    )
  end

  def touch_conversation
    conversation.touch
  end
end
