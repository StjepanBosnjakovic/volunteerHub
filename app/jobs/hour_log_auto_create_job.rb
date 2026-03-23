# Auto-creates an HourLog record when a volunteer checks out of a shift.
# Triggered from Attendance#check_out!
class HourLogAutoCreateJob < ApplicationJob
  queue_as :default

  def perform(attendance_id)
    attendance = Attendance.find_by(id: attendance_id)
    return unless attendance
    return unless attendance.duration_hours&.positive?
    return if HourLog.exists?(attendance: attendance)

    assignment = attendance.shift_assignment
    shift      = assignment.shift
    profile    = assignment.volunteer_profile

    org_auto_approve = profile.organisation.auto_approve_hours?

    HourLog.create!(
      volunteer_profile: profile,
      organisation:      profile.organisation,
      program:           shift.program,
      shift:             shift,
      attendance:        attendance,
      date:              shift.starts_at.to_date,
      hours:             attendance.duration_hours,
      description:       "Auto-logged from shift: #{shift.title}",
      source:            :auto,
      status:            org_auto_approve ? :approved : :pending
    )
  end
end
