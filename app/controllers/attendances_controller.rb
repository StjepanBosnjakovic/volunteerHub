class AttendancesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:qr_checkin]
  before_action :set_shift, except: [:qr_checkin]
  before_action :set_assignment, except: [:qr_checkin]

  def toggle
    authorize Attendance, :update?
    attendance = @assignment.attendance || @assignment.build_attendance

    if attendance.checked_in?
      attendance.check_out!
      message = "Checked out."
    else
      attendance.check_in!(check_method: :manual)
      message = "Checked in."
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "attendance_#{@assignment.id}",
          partial: "attendances/row",
          locals: { assignment: @assignment, shift: @shift }
        )
      end
      format.html { redirect_to checkin_program_shift_path(@program, @shift), notice: message }
    end
  end

  def qr_checkin
    shift = Shift.find_by(qr_token: params[:qr_token])
    return render plain: "Invalid QR token", status: :not_found unless shift

    if user_signed_in?
      profile = current_user.volunteer_profile
      assignment = shift.shift_assignments.find_by(volunteer_profile: profile) if profile
      if assignment
        attendance = assignment.attendance || assignment.build_attendance
        attendance.check_in!(check_method: :qr) unless attendance.checked_in?
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "checkin_status",
              partial: "attendances/checkin_status",
              locals: { shift: shift, attendance: attendance }
            )
          end
          format.html do
            redirect_to program_shift_path(shift.program, shift),
              notice: "Checked in via QR code."
          end
        end
      else
        redirect_to program_shift_path(shift.program, shift), alert: "You are not assigned to this shift."
      end
    else
      redirect_to new_user_session_path, alert: "Please sign in to check in."
    end
  end

  private

  def set_shift
    @program = policy_scope(Program).find(params[:program_id])
    @shift = @program.shifts.find(params[:shift_id])
  end

  def set_assignment
    @assignment = @shift.shift_assignments.find(params[:shift_assignment_id])
  end
end
