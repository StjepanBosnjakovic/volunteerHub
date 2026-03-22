# Runs after shift end — flags missing Attendance records as no-shows
# and queues a follow-up message to the coordinator.
class DetectNoShowsJob < ApplicationJob
  queue_as :default

  def perform(shift_id)
    shift = Shift.find_by(id: shift_id)
    return unless shift
    return unless shift.ends_at < Time.current

    shift.shift_assignments.confirmed.includes(:attendance, :volunteer_profile).each do |assignment|
      next if assignment.attendance&.checked_in?

      # Mark as no-show
      attendance = assignment.attendance || assignment.build_attendance
      attendance.update!(no_show: true)

      # Notification hook — Phase 5 will deliver the actual message
      Rails.logger.info "[DetectNoShowsJob] No-show flagged: volunteer=#{assignment.volunteer_profile_id} shift=#{shift_id}"
    end
  end
end
