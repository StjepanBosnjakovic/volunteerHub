class ShiftAssignmentsController < ApplicationController
  before_action :set_program
  before_action :set_shift
  before_action :set_assignment, only: %i[destroy]

  def create
    volunteer_profile = resolve_volunteer_profile
    return redirect_to program_shift_path(@program, @shift), alert: "No volunteer profile found." unless volunteer_profile

    @assignment = @shift.shift_assignments.build(
      volunteer_profile: volunteer_profile,
      shift_role_id: params[:shift_assignment]&.dig(:shift_role_id)
    )
    authorize @assignment

    # Check capacity
    status = if @shift.full?
      if @shift.waitlist_enabled
        :waitlisted
      else
        return redirect_to program_shift_path(@program, @shift), alert: "Shift is full."
      end
    else
      :confirmed
    end
    @assignment.status = status

    if @assignment.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("shift_capacity_#{@shift.id}", partial: "shifts/capacity", locals: { shift: @shift }),
            turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { notice: "Signed up for shift." })
          ]
        end
        format.html { redirect_to program_shift_path(@program, @shift), notice: "Signed up for shift." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash_messages",
            partial: "shared/flash", locals: { alert: @assignment.errors.full_messages.to_sentence })
        end
        format.html { redirect_to program_shift_path(@program, @shift), alert: @assignment.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    authorize @assignment
    @assignment.cancel!(current_user)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("shift_capacity_#{@shift.id}", partial: "shifts/capacity", locals: { shift: @shift }),
          turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { notice: "Shift cancelled." })
        ]
      end
      format.html { redirect_to program_shift_path(@program, @shift), notice: "Shift cancelled." }
    end
  end

  def bulk_assign
    authorize ShiftAssignment, :create?
    volunteer_ids = params[:volunteer_profile_ids] || []
    assigned = 0
    volunteer_ids.each do |vid|
      profile = VolunteerProfile.find_by(id: vid, organisation: current_user.organisation)
      next unless profile
      next if @shift.shift_assignments.where(volunteer_profile: profile).exists?
      status = @shift.full? ? (:waitlisted if @shift.waitlist_enabled) : :confirmed
      next unless status
      @shift.shift_assignments.create(volunteer_profile: profile, status: status)
      assigned += 1
    end
    redirect_to program_shift_path(@program, @shift), notice: "#{assigned} volunteer(s) assigned."
  end

  private

  def set_program
    @program = policy_scope(Program).find(params[:program_id])
  end

  def set_shift
    @shift = @program.shifts.find(params[:shift_id])
  end

  def set_assignment
    @assignment = @shift.shift_assignments.find(params[:id])
  end

  def resolve_volunteer_profile
    if current_user.admin? && params[:shift_assignment]&.dig(:volunteer_profile_id).present?
      VolunteerProfile.find_by(id: params[:shift_assignment][:volunteer_profile_id],
                                organisation: current_user.organisation)
    else
      current_user.volunteer_profile
    end
  end
end
