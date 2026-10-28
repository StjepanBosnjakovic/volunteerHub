class DashboardController < ApplicationController
  UPCOMING_WINDOW = 30.days

  def index
    @organisation = current_user.organisation
    @total_volunteers = policy_scope(VolunteerProfile).count
    @active_volunteers = policy_scope(VolunteerProfile).status_active.count
    @pending_volunteers = policy_scope(VolunteerProfile).status_pending.count
    @expiring_credentials = Credential.joins(:volunteer_profile)
                                      .where(volunteer_profiles: { organisation: @organisation })
                                      .expiring_within(30).count

    shifts = Shift.where(program: policy_scope(Program))
    @upcoming_shifts = shifts.upcoming.where("starts_at < ?", UPCOMING_WINDOW.from_now).ordered
                             .includes(:program, shift_assignments: :volunteer_profile).to_a
    @shifts_needing = @upcoming_shifts.select { |s| s.capacity && s.shift_assignments.count(&:confirmed?) < s.capacity }.first(4)
    @recent_signups = ShiftAssignment.where(shift: shifts).order(created_at: :desc).limit(6)
                                     .includes(:volunteer_profile, :shift)
  end
end
