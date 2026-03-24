class NotificationsController < ApplicationController
  include Pagy::Method

  before_action :set_notification, only: %i[mark_read]

  def index
    authorize Notification
    @pagy, @notifications = pagy(
      current_user.notifications.ordered,
      items: 30
    )
  end

  def mark_read
    authorize @notification
    @notification.read!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "notification_#{@notification.id}",
            partial: "notifications/notification",
            locals:  { notification: @notification }
          ),
          turbo_stream.replace(
            "notification_bell_count",
            partial: "shared/notification_bell_count",
            locals:  { count: current_user.notifications.unread.count }
          )
        ]
      end
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_read
    authorize Notification, :mark_all_read?
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "notification_bell_count",
          partial: "shared/notification_bell_count",
          locals:  { count: 0 }
        )
      end
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
