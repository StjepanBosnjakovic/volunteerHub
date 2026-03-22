# Sends shift reminders to confirmed volunteers N hours before start.
# Scheduled via Sidekiq-cron (see config/sidekiq.yml) or enqueued
# at shift creation with `perform_in`.
class ShiftReminderJob < ApplicationJob
  queue_as :default

  def perform(shift_id)
    shift = Shift.find_by(id: shift_id)
    return unless shift
    return if shift.starts_at < Time.current

    shift.shift_assignments.confirmed.includes(:volunteer_profile).each do |assignment|
      # Phase 5 will deliver via NotificationMailer / in-app
      Rails.logger.info "[ShiftReminderJob] Reminder queued: volunteer=#{assignment.volunteer_profile_id} shift=#{shift_id}"
    end
  end
end
