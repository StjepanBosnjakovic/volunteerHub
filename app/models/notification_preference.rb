class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user,              presence: true
  validates :notification_type, presence: true,
                                inclusion: { in: Notification::TYPES }
  validates :notification_type, uniqueness: { scope: :user_id }

  scope :for_user, ->(user) { where(user: user) }

  def self.defaults_for(user)
    Notification::TYPES.each do |type|
      find_or_create_by!(user: user, notification_type: type) do |pref|
        pref.in_app = true
        pref.email  = true
      end
    end
  end
end
