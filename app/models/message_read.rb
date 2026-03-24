class MessageRead < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :message,  presence: true
  validates :user,     presence: true
  validates :read_at,  presence: true
  validates :user_id, uniqueness: { scope: :message_id }

  before_validation :set_read_at

  private

  def set_read_at
    self.read_at ||= Time.current
  end
end
