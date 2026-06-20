# Sends nudges to volunteers who have not logged any hours or checked in
# for a configurable number of days (default: 60).
# Intended to be run on a weekly Sidekiq cron schedule.
class InactivityNudgeJob < ApplicationJob
  queue_as :default

  INACTIVITY_DAYS = 60

  def perform
    Organisation.find_each do |organisation|
      ActsAsTenant.with_tenant(organisation) do
        nudge_inactive_volunteers(organisation)
      end
    end
  end

  private

  def nudge_inactive_volunteers(organisation)
    cutoff = INACTIVITY_DAYS.days.ago

    inactive_users = organisation.users
      .where(role: :volunteer)
      .joins(:volunteer_profile)
      .where(volunteer_profiles: { status: :active })
      .where.not(
        id: organisation.hour_logs
          .where("date >= ?", cutoff)
          .select(:volunteer_profile_id)
          .joins(volunteer_profile: :user)
          .select("users.id")
      )

    inactive_users.find_each do |user|
      already_nudged = user.notifications
        .where(notification_type: "inactivity_nudge")
        .where("created_at > ?", cutoff)
        .exists?

      next if already_nudged

      Notification.create_for(
        recipient:  user,
        type:       "inactivity_nudge",
        data:       {
          message:       "We miss you! Check out upcoming volunteer opportunities.",
          dashboard_url: Rails.application.routes.url_helpers.dashboard_url(host: ENV.fetch("APP_HOST", "localhost"))
        }
      )

      Rails.logger.info "[InactivityNudgeJob] Nudged volunteer user_id=#{user.id}"
    end
  end
end
