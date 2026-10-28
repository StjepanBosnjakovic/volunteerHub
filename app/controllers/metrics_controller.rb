require "sidekiq/api"

# Exposes app metrics in the Prometheus text format for server monitoring.
# The endpoint is off unless METRICS_TOKEN is set. Callers send "Authorization: Bearer <token>".
class MetricsController < ActionController::Base
  before_action :authenticate_token

  def show
    render plain: prometheus_text(metrics), content_type: "text/plain; version=0.0.4"
  end

  private

  def authenticate_token
    token = ENV["METRICS_TOKEN"].to_s
    provided = request.authorization.to_s.delete_prefix("Bearer ")
    head :not_found if token.blank? || !ActiveSupport::SecurityUtils.secure_compare(provided, token)
  end

  def metrics
    sidekiq = Sidekiq::Stats.new

    ActsAsTenant.without_tenant do
      {
        "volunteerhub_organisations" => Organisation.count,
        "volunteerhub_users" => labelled("role", User.group(:role).count),
        "volunteerhub_volunteer_profiles" => labelled("status", VolunteerProfile.group(:status).count),
        "volunteerhub_volunteer_applications" => labelled("status", VolunteerApplication.group(:status).count),
        "volunteerhub_shifts_upcoming" => Shift.where(starts_at: Time.current..).count,
        "volunteerhub_shift_assignments" => labelled("status", ShiftAssignment.group(:status).count),
        "volunteerhub_approved_hours" => HourLog.approved.sum(:hours).to_f,
        "volunteerhub_database_size_bytes" => ActiveRecord::Base.connection.select_value("SELECT pg_database_size(current_database())"),
        "volunteerhub_sidekiq_processed" => sidekiq.processed,
        "volunteerhub_sidekiq_failed" => sidekiq.failed,
        "volunteerhub_sidekiq_enqueued" => sidekiq.enqueued,
        "volunteerhub_sidekiq_retries" => sidekiq.retry_size,
        "volunteerhub_sidekiq_dead" => sidekiq.dead_size,
        "volunteerhub_sidekiq_busy" => sidekiq.workers_size
      }
    end
  end

  # Turns { "active" => 3 } into { 'status="active"' => 3 }.
  def labelled(label, counts)
    counts.transform_keys { |value| %(#{label}="#{value}") }
  end

  def prometheus_text(metrics)
    metrics.flat_map do |name, value|
      samples = value.is_a?(Hash) ? value.map { |labels, v| "#{name}{#{labels}} #{v}" } : [ "#{name} #{value}" ]
      [ "# TYPE #{name} gauge", *samples ]
    end.join("\n") + "\n"
  end
end
