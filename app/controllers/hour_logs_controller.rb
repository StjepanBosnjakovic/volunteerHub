class HourLogsController < ApplicationController
  include Pagy::Method

  before_action :set_hour_log, only: %i[show edit update destroy approve reject dispute]

  def index
    authorize HourLog
    @tab = params[:tab] || (current_user.admin? ? "pending" : "mine")

    filtered = policy_scope(HourLog).includes(:volunteer_profile, :program, :shift).ordered

    if params[:program_id].present?
      filtered = filtered.where(program_id: params[:program_id])
    end

    if params[:from].present? && params[:to].present?
      filtered = filtered.in_period(Date.parse(params[:from]), Date.parse(params[:to]))
    end

    by_tab = {
      "pending" => filtered.pending,
      "approved" => filtered.approved,
      "rejected" => filtered.rejected,
      "disputed" => filtered.disputed
    }
    logs = by_tab.fetch(@tab, filtered)

    respond_to do |format|
      format.html do
        @pagy, @hour_logs = pagy(logs, items: 25)
        @programs = policy_scope(Program).ordered
        @tab_counts = by_tab.transform_values(&:count).merge("mine" => filtered.count)
        load_stats
      end
      format.csv do
        send_data generate_csv(logs), filename: "hour-logs-#{Date.current}.csv", type: "text/csv"
      end
    end
  end

  def show
    authorize @hour_log
  end

  def new
    authorize HourLog
    @hour_log = HourLog.new
    @programs = policy_scope(Program).ordered
  end

  def create
    authorize HourLog
    profile = current_user.volunteer_profile

    @hour_log = HourLog.new(hour_log_params)
    @hour_log.volunteer_profile = profile if current_user.role_volunteer?
    @hour_log.organisation = current_user.organisation
    @hour_log.source = :self_logged

    if @hour_log.save
      redirect_to hour_logs_path, notice: "Hours submitted and pending approval."
    else
      @programs = policy_scope(Program).ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @hour_log
    @programs = policy_scope(Program).ordered
  end

  def update
    authorize @hour_log

    if @hour_log.update(hour_log_params)
      redirect_to hour_logs_path, notice: "Hour log updated."
    else
      @programs = policy_scope(Program).ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @hour_log
    @hour_log.destroy
    redirect_to hour_logs_path, notice: "Hour log deleted."
  end

  def approve
    authorize @hour_log
    @hour_log.approve!(by: current_user)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "hour_log_#{@hour_log.id}",
          partial: "hour_logs/row",
          locals: { hour_log: @hour_log }
        )
      end
      format.html { redirect_to hour_logs_path(tab: "pending"), notice: "Hours approved." }
    end
  end

  def reject
    authorize @hour_log
    @hour_log.reject!(by: current_user, reason: params[:rejection_reason])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "hour_log_#{@hour_log.id}",
          partial: "hour_logs/row",
          locals: { hour_log: @hour_log }
        )
      end
      format.html { redirect_to hour_logs_path(tab: "pending"), notice: "Hours rejected." }
    end
  end

  def dispute
    authorize @hour_log
    @hour_log.dispute!(note: params[:dispute_note])
    redirect_to hour_logs_path, notice: "Hours flagged for coordinator review."
  end

  def bulk_import
    authorize HourLog, :bulk_import?
    return unless request.post?

    if params[:csv_file].present?
      csv_content = params[:csv_file].read
      HourBulkImportJob.perform_later(csv_content, current_user.organisation_id, current_user.id)
      redirect_to hour_logs_path, notice: "Import started. You will be notified when complete."
    else
      flash[:alert] = "Please select a CSV file."
      render :bulk_import
    end
  end

  private

  def load_stats
    scope = policy_scope(HourLog)
    this_month = scope.approved.in_period(Date.current.beginning_of_month, Date.current.end_of_month)
    last_month = scope.approved.in_period(1.month.ago.to_date.beginning_of_month, 1.month.ago.to_date.end_of_month)
    pending = scope.pending
    @stats = {
      month_hours: this_month.sum(:hours),
      last_month_hours: last_month.sum(:hours),
      pending: pending.count,
      pending_volunteers: pending.distinct.count(:volunteer_profile_id),
      total_hours: scope.approved.sum(:hours),
      active_volunteers: this_month.distinct.count(:volunteer_profile_id)
    }
  end

  def set_hour_log
    @hour_log = policy_scope(HourLog).find(params[:id])
  end

  def hour_log_params
    params.require(:hour_log).permit(:volunteer_profile_id, :program_id, :shift_id,
      :date, :hours, :description)
  end

  def generate_csv(logs)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << %w[id volunteer program shift date hours description status source approved_at]
      logs.each do |log|
        csv << [
          log.id,
          log.volunteer_profile.full_name,
          log.program.name,
          log.shift&.title,
          log.date,
          log.hours,
          log.description,
          log.status,
          log.source,
          log.approved_at
        ]
      end
    end
  end
end
