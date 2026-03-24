class User < ApplicationRecord
  acts_as_tenant :organisation

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable

  enum :role, { super_admin: 0, coordinator: 1, read_only_staff: 2, volunteer: 3 }, prefix: true

  belongs_to :organisation
  has_one :volunteer_profile, dependent: :destroy
  has_many :coordinator_programs, dependent: :destroy

  # Phase 5 — Communications
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :notification_preferences, dependent: :destroy
  has_many :sent_broadcasts, class_name: "BroadcastMessage", foreign_key: :sender_id, dependent: :destroy
  has_many :authored_announcements, class_name: "Announcement", foreign_key: :author_id, dependent: :destroy
  has_many :sent_campaigns, class_name: "EmailCampaign", foreign_key: :sender_id, dependent: :destroy

  validates :role, presence: true

  scope :coordinators, -> { where(role: :coordinator) }
  scope :volunteers, -> { where(role: :volunteer) }

  def display_name
    volunteer_profile&.full_name || email
  end

  def admin?
    role_super_admin? || role_coordinator?
  end
end
