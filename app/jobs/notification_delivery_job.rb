# Sends an email for a given Notification record.
class NotificationDeliveryJob < ApplicationJob
  queue_as :mailers

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    ActsAsTenant.with_tenant(notification.organisation) do
      NotificationMailer.notify(notification).deliver_now
    end
  end
end
