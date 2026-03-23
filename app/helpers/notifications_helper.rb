module NotificationsHelper
  def notification_message(notification)
    data = notification.data || {}
    case notification.notification_type
    when "shift_reminder"
      "Reminder: #{data['shift_title']} on #{data['shift_date']}"
    when "hour_approved"
      "Your #{data['hours']} hours for #{data['program_name']} were approved"
    when "hour_rejected"
      "Your hours submission for #{data['program_name']} requires attention"
    when "milestone_reached"
      "You reached the #{data['milestone_label']} milestone!"
    when "onboarding_stall"
      "You have incomplete onboarding steps"
    when "credential_expiry"
      "#{data['credential_name']} expires in #{data['days_until_expiry']} days"
    when "swap_request"
      "Shift swap request update"
    when "broadcast"
      data["subject"] || "New message from your organisation"
    when "announcement"
      "New announcement: #{data['title']}"
    when "message_received"
      "You have a new message from #{data['sender_name']}"
    when "inactivity_nudge"
      "We miss you! Check out upcoming volunteer opportunities"
    else
      "You have a new notification"
    end
  end

  def notification_icon(type)
    icons = {
      "shift_reminder"   => <<~SVG,
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
        </svg>
      SVG
      "hour_approved"    => <<~SVG,
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
      SVG
      "milestone_reached" => <<~SVG,
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
        </svg>
      SVG
      "message_received" => <<~SVG,
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
        </svg>
      SVG
      "announcement"     => <<~SVG
        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"/>
        </svg>
      SVG
    }
    default_svg = <<~SVG
      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
      </svg>
    SVG

    (icons[type] || default_svg).html_safe
  end

  def notification_icon_color(type)
    colors = {
      "hour_approved"     => "bg-green-100 text-green-600",
      "milestone_reached" => "bg-yellow-100 text-yellow-600",
      "hour_rejected"     => "bg-red-100 text-red-600",
      "credential_expiry" => "bg-orange-100 text-orange-600",
      "message_received"  => "bg-indigo-100 text-indigo-600",
      "announcement"      => "bg-blue-100 text-blue-600",
      "shift_reminder"    => "bg-purple-100 text-purple-600"
    }
    colors[type] || "bg-gray-100 text-gray-600"
  end
end
