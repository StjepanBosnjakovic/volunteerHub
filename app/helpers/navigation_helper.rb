module NavigationHelper
  NavItem = Struct.new(:label, :path, :icon, :count, :match, keyword_init: true)

  def primary_nav_items
    @primary_nav_items ||= build_primary_nav_items
  end

  def build_primary_nav_items
    items = [
      NavItem.new(label: "Dashboard", path: dashboard_path, icon: "layout-dashboard", match: %w[dashboard]),
      NavItem.new(label: "Opportunities", path: opportunities_path, icon: "sparkles", match: %w[opportunities volunteer_applications]),
      NavItem.new(label: "Programs", path: programs_path, icon: "calendar-days", match: %w[programs shifts]),
      NavItem.new(label: "Volunteers", path: volunteer_profiles_path, icon: "users", match: %w[volunteer_profiles]),
      NavItem.new(label: "Onboarding", path: onboarding_checklists_path, icon: "clipboard-check", match: %w[onboarding_checklists]),
      NavItem.new(label: "Hours", path: hour_logs_path, icon: "clock", count: pending_hours_count, match: %w[hour_logs]),
      NavItem.new(label: "Messages", path: conversations_path, icon: "message-circle", count: unread_messages_count, match: %w[conversations]),
      NavItem.new(label: "Announcements", path: announcements_path, icon: "inbox", match: %w[announcements])
    ]
    if current_user.admin?
      items << NavItem.new(label: "Broadcasts", path: broadcast_messages_path, icon: "megaphone", match: %w[broadcast_messages])
      items << NavItem.new(label: "Swap Requests", path: swap_requests_path, icon: "arrow-left-right", match: %w[swap_requests])
      items << NavItem.new(label: "Milestones", path: milestones_path, icon: "trophy", match: %w[milestones])
    end
    items
  end

  def secondary_nav_items
    return [] unless current_user.admin?

    [NavItem.new(label: "Organisation", path: organisation_path, icon: "settings", match: %w[organisations])]
  end

  def nav_item_active?(item)
    item.match.include?(controller_name)
  end

  private

  def pending_hours_count
    return unless current_user.admin?

    count = policy_scope(HourLog).pending.count
    count if count.positive?
  end

  def unread_messages_count
    count = Message.joins(conversation: :conversation_participants)
                   .where(conversation_participants: { user_id: current_user.id })
                   .where.not(sender_id: current_user.id)
                   .where("conversation_participants.last_read_at IS NULL OR messages.created_at > conversation_participants.last_read_at")
                   .count
    count if count.positive?
  end
end
