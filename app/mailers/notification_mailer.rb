class NotificationMailer < ApplicationMailer
  def notify(notification)
    @notification = notification
    @user         = notification.recipient
    @organisation = notification.organisation
    @data         = notification.data || {}

    subject = build_subject(notification.notification_type)

    mail(
      to:      @user.email,
      subject: subject,
      from:    sender_address(@organisation)
    )
  end

  private

  def build_subject(type)
    case type
    when "shift_reminder"     then "Upcoming shift reminder"
    when "hour_approved"      then "Your hours have been approved"
    when "hour_rejected"      then "Hours submission requires attention"
    when "milestone_reached"  then "Congratulations on your new milestone!"
    when "onboarding_stall"   then "Complete your onboarding"
    when "credential_expiry"  then "Credential expiring soon"
    when "swap_request"       then "Shift swap request update"
    when "broadcast"          then @data["subject"] || "Message from #{@organisation.name}"
    when "announcement"       then @data["title"] || "New announcement"
    when "message_received"   then "New message"
    when "inactivity_nudge"   then "We miss you, #{@user.display_name}!"
    else "Notification from #{@organisation.name}"
    end
  end

  def sender_address(org)
    if org.email_sender_address.present?
      "#{org.email_sender_name} <#{org.email_sender_address}>"
    else
      default_from
    end
  end
end
