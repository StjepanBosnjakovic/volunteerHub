class ShiftsController < ApplicationController
  include Pagy::Method

  before_action :set_program
  before_action :set_shift, only: %i[show edit update destroy clone checkin export_pdf ical]

  def index
    authorize Shift
    @shifts = @program.shifts.ordered.includes(:shift_assignments, :shift_roles)

    @shifts = @shifts.where("starts_at >= ?", Date.parse(params[:from])) if params[:from].present?
    @shifts = @shifts.where("starts_at <= ?", Date.parse(params[:to])) if params[:to].present?

    respond_to do |format|
      format.html do
        @pagy, @shifts = pagy(@shifts, items: 20)
      end
      format.turbo_stream
    end
  end

  def show
    authorize @shift
    @assignments = @shift.shift_assignments.includes(:volunteer_profile, :attendance)
    @my_assignment = current_user.volunteer_profile &&
      @shift.shift_assignments.find_by(volunteer_profile: current_user.volunteer_profile)
    @suggestions = suggested_volunteers if current_user.admin?
  end

  def new
    authorize Shift
    @shift = @program.shifts.build
    @shift.shift_roles.build
  end

  def create
    authorize Shift
    @shift = @program.shifts.build(shift_params)
    @shift.coordinator = current_user if current_user.role_coordinator?

    if @shift.save
      if params[:recurring] == "1" && @shift.recurrence_rule.present?
        generate_recurring_shifts(@shift)
      end
      redirect_to program_shift_path(@program, @shift), notice: "Shift created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @shift
  end

  def update
    authorize @shift

    if @shift.update(shift_params)
      redirect_to program_shift_path(@program, @shift), notice: "Shift updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @shift
    @shift.destroy
    redirect_to program_shifts_path(@program), notice: "Shift deleted."
  end

  def clone
    authorize @shift, :create?
    new_shift = @shift.dup
    new_shift.shift_roles = @shift.shift_roles.map(&:dup)
    new_shift.qr_token = nil
    new_shift.starts_at = params[:starts_at].present? ? Time.parse(params[:starts_at]) : @shift.starts_at + 1.week
    new_shift.ends_at = new_shift.starts_at + (@shift.ends_at - @shift.starts_at)

    if new_shift.save
      redirect_to program_shift_path(@program, new_shift), notice: "Shift cloned."
    else
      redirect_to program_shift_path(@program, @shift), alert: "Could not clone shift."
    end
  end

  def checkin
    authorize @shift, :checkin?
  end

  def export_pdf
    authorize @shift, :export_pdf?
    pdf_content = generate_schedule_pdf(@shift)
    send_data pdf_content, filename: "shift-#{@shift.id}-schedule.pdf", type: "application/pdf"
  end

  def ical
    authorize @shift, :ical?
    cal = build_ical(@shift)
    send_data cal, filename: "shift-#{@shift.id}.ics", type: "text/calendar"
  end

  private

  def set_program
    @program = policy_scope(Program).find(params[:program_id])
  end

  def set_shift
    @shift = @program.shifts.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(
      :title, :location, :lat, :lng, :starts_at, :ends_at,
      :capacity, :waitlist_enabled, :notes, :recurrence_rule,
      :coordinator_id, :cancellation_cutoff_hours,
      shift_roles_attributes: [:id, :label, :spots, :_destroy]
    )
  end

  def suggested_volunteers
    VolunteerProfile
      .where(organisation: current_user.organisation)
      .status_active
      .where.not(id: @shift.shift_assignments.select(:volunteer_profile_id))
      .limit(10)
  end

  def generate_recurring_shifts(template_shift)
    occurrences = template_shift.generate_occurrences(limit: 12)
    occurrences.drop(1).each do |occurrence_shift|
      occurrence_shift.save
    end
  end

  def generate_schedule_pdf(shift)
    require "prawn"
    Prawn::Document.new do |pdf|
      pdf.text "#{shift.title} — Schedule", size: 18, style: :bold
      pdf.text "#{shift.starts_at.strftime('%A, %B %-d %Y, %H:%M')} – #{shift.ends_at.strftime('%H:%M')}"
      pdf.text "Location: #{shift.location}" if shift.location.present?
      pdf.move_down 10
      pdf.text "Assigned Volunteers:", style: :bold
      shift.shift_assignments.confirmed.includes(:volunteer_profile).each do |sa|
        pdf.text "• #{sa.volunteer_profile.full_name}"
      end
    end.render
  end

  def build_ical(shift)
    uid = "shift-#{shift.id}@volunteerOS"
    dtstamp = Time.current.utc.strftime("%Y%m%dT%H%M%SZ")
    dtstart = shift.starts_at.utc.strftime("%Y%m%dT%H%M%SZ")
    dtend = shift.ends_at.utc.strftime("%Y%m%dT%H%M%SZ")
    summary = shift.title.gsub(",", "\\,")
    location = shift.location.to_s.gsub(",", "\\,")

    <<~ICAL
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//VolunteerOS//Shift//EN
      BEGIN:VEVENT
      UID:#{uid}
      DTSTAMP:#{dtstamp}
      DTSTART:#{dtstart}
      DTEND:#{dtend}
      SUMMARY:#{summary}
      LOCATION:#{location}
      END:VEVENT
      END:VCALENDAR
    ICAL
  end
end
