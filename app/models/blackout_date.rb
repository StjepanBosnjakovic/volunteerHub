class BlackoutDate < ApplicationRecord
  belongs_to :volunteer_profile

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :upcoming, -> { where("end_date >= ?", Date.current).order(:start_date) }

  private

  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, "must be on or after start date") if end_date < start_date
  end
end
