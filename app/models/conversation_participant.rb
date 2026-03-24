class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :conversation, presence: true
  validates :user,         presence: true
  validates :user_id, uniqueness: { scope: :conversation_id, message: "is already a participant" }
end
