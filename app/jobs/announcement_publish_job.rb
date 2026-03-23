# Publishes a scheduled Announcement at the designated time.
# Runs after the scheduled_for datetime via .set(wait_until: ...).
class AnnouncementPublishJob < ApplicationJob
  queue_as :default

  def perform(announcement_id)
    announcement = Announcement.find_by(id: announcement_id)
    return unless announcement
    return unless announcement.scheduled?

    ActsAsTenant.with_tenant(announcement.organisation) do
      announcement.publish!

      # Notify all active volunteers
      announcement.organisation.users.where(role: :volunteer).find_each do |user|
        Notification.create_for(
          recipient:  user,
          type:       "announcement",
          data:       { title: announcement.title, announcement_id: announcement.id },
          notifiable: announcement
        )
      end

      Rails.logger.info "[AnnouncementPublishJob] Published announcement #{announcement_id}"
    end
  end
end
