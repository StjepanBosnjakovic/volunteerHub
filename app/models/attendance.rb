class Attendance < ApplicationRecord
  belongs_to :shift_assignment

  enum :method, { manual: 0, qr: 1, geo: 2 }

  validates :shift_assignment, presence: true

  delegate :shift, :volunteer_profile, to: :shift_assignment

  def checked_in?
    checked_in_at.present?
  end

  def checked_out?
    checked_out_at.present?
  end

  def duration_hours
    return nil unless checked_in? && checked_out?
    ((checked_out_at - checked_in_at) / 3600.0).round(2)
  end

  def check_in!(check_method: :manual)
    update!(checked_in_at: Time.current, method: check_method)
  end

  def check_out!
    update!(checked_out_at: Time.current)
    HourLogAutoCreateJob.perform_later(id) if duration_hours&.positive?
  end
end
