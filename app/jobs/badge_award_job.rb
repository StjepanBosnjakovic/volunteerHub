# Evaluates auto-awardable badges for a volunteer profile.
# Triggered after milestone reached, HourLog approval, or consecutive-month calculation.
class BadgeAwardJob < ApplicationJob
  queue_as :default

  def perform(volunteer_profile_id)
    profile = VolunteerProfile.find_by(id: volunteer_profile_id)
    return unless profile

    ActsAsTenant.with_tenant(profile.organisation) do
      total_hours = profile.hour_logs.approved.sum(:hours)
      months_active = consecutive_active_months(profile)

      Badge.where("organisation_id IS NULL OR organisation_id = ?", profile.organisation_id)
           .where.not(criteria_type: "manual")
           .each do |badge|
        next if profile.volunteer_badges.exists?(badge: badge)

        earned = badge_earned?(badge, total_hours, months_active, profile)

        next unless earned

        profile.volunteer_badges.create!(
          badge:      badge,
          awarded_at: Time.current
        )

        Rails.logger.info "[BadgeAwardJob] Badge '#{badge.name}' awarded to " \
                          "volunteer_profile=#{volunteer_profile_id}"
      end
    end
  end

  private

  def badge_earned?(badge, total_hours, months_active, profile)
    case badge.criteria_type
    when "hours_reached"
      badge.criteria_value.present? && total_hours >= badge.criteria_value
    when "milestone"
      badge.criteria_value.present? &&
        profile.volunteer_milestones
               .joins(:milestone)
               .where("milestones.threshold_hours >= ?", badge.criteria_value)
               .exists?
    when "consecutive_months"
      badge.criteria_value.present? && months_active >= badge.criteria_value
    else
      false
    end
  end

  # Count distinct calendar months in which the volunteer had at least one approved hour log
  def consecutive_active_months(profile)
    months = profile.hour_logs.approved
                    .select("DATE_TRUNC('month', date) AS month")
                    .distinct
                    .order("month DESC")
                    .pluck(Arel.sql("DATE_TRUNC('month', date)"))

    return 0 if months.empty?

    streak    = 1
    max_streak = 1
    months.each_cons(2) do |later, earlier|
      if later.prev_month.beginning_of_month == earlier.beginning_of_month
        streak += 1
        max_streak = [max_streak, streak].max
      else
        streak = 1
      end
    end

    max_streak
  end
end
