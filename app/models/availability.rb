class Availability < ApplicationRecord
  belongs_to :volunteer_profile

  DAYS_OF_WEEK = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :time_blocks, presence: true

  def day_name
    DAYS_OF_WEEK[day_of_week]
  end
end
