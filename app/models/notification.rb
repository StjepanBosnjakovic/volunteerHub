class Notification < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :recipient,    class_name: "User"
  belongs_to :organisation
  belongs_to :notifiable,   polymorphic: true, optional: true

  validates :recipient,          presence: true
  validates :notification_type,  presence: true

  scope :unread,   -> { where(read_at: nil) }
  scope :read,     -> { where.not(read_at: nil) }
  scope :ordered,  -> { order(created_at: :desc) }
  scope :recent,   -> { ordered.limit(20) }

  TYPES = %w[
    shift_reminder
    hour_approved
    hour_rejected
    milestone_reached
    onboarding_stall
    credential_expiry
    swap_request
    broadcast
    announcement
    message_received
    inactivity_nudge
  ].freeze

  after_create_commit :broadcast_bell_count

  def read!
    update!(read_at: Time.current) unless read_at
  end

  def unread?
    read_at.nil?
  end

  def self.create_for(recipient:, type:, data: {}, notifiable: nil)
    organisation = recipient.organisation
    return unless recipient_wants_in_app?(recipient, type)

    notification = create!(
      recipient:         recipient,
      organisation:      organisation,
      notification_type: type,
      data:              data,
      notifiable:        notifiable
    )

    if recipient_wants_email?(recipient, type)
      NotificationDeliveryJob.perform_later(notification.id)
    end

    notification
  end

  def self.recipient_wants_in_app?(recipient, type)
    pref = NotificationPreference.find_by(user: recipient, notification_type: type)
    pref ? pref.in_app : true
  end

  def self.recipient_wants_email?(recipient, type)
    pref = NotificationPreference.find_by(user: recipient, notification_type: type)
    pref ? pref.email : true
  end

  private

  def broadcast_bell_count
    count = recipient.notifications.unread.count
    Turbo::StreamsChannel.broadcast_replace_to(
      "notifications_#{recipient_id}",
      target:  "notification_bell_count",
      partial: "shared/notification_bell_count",
      locals:  { count: count }
    )
  end
end
