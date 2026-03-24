class LeaderboardController < ApplicationController
  include Pagy::Method

  def index
    authorize :leaderboard, :index?

    @period  = params[:period].presence_in(%w[week month quarter year all]) || "month"
    @metric  = params[:metric].presence_in(%w[hours shifts badges]) || "hours"
    @program = params[:program_id].present? ? Program.find_by(id: params[:program_id]) : nil

    @programs = policy_scope(Program)

    scope = VolunteerProfile.where(show_on_leaderboard: true)

    @pagy, @entries = pagy(build_leaderboard(scope), items: 25)
  end

  private

  def build_leaderboard(scope)
    case @metric
    when "hours"
      hour_logs = HourLog.approved
      hour_logs = hour_logs.where(program: @program) if @program
      hour_logs = hour_logs.where("date >= ?", period_start) unless @period == "all"

      scope
        .joins("LEFT JOIN hour_logs ON hour_logs.volunteer_profile_id = volunteer_profiles.id " \
               "AND hour_logs.status = 1" +
               (@program ? " AND hour_logs.program_id = #{@program.id}" : "") +
               (@period != "all" ? " AND hour_logs.date >= '#{period_start}'" : ""))
        .select("volunteer_profiles.*, COALESCE(SUM(hour_logs.hours), 0) AS metric_value")
        .group("volunteer_profiles.id")
        .order("metric_value DESC")
    when "shifts"
      scope
        .joins("LEFT JOIN shift_assignments ON shift_assignments.volunteer_profile_id = volunteer_profiles.id " \
               "AND shift_assignments.status = 1")
        .select("volunteer_profiles.*, COUNT(DISTINCT shift_assignments.id) AS metric_value")
        .group("volunteer_profiles.id")
        .order("metric_value DESC")
    when "badges"
      scope
        .joins("LEFT JOIN volunteer_badges ON volunteer_badges.volunteer_profile_id = volunteer_profiles.id")
        .select("volunteer_profiles.*, COUNT(DISTINCT volunteer_badges.id) AS metric_value")
        .group("volunteer_profiles.id")
        .order("metric_value DESC")
    end
  end

  def period_start
    case @period
    when "week"    then 1.week.ago.beginning_of_day
    when "month"   then 1.month.ago.beginning_of_day
    when "quarter" then 3.months.ago.beginning_of_day
    when "year"    then 1.year.ago.beginning_of_day
    end
  end
end
