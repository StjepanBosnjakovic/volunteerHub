class Credential < ApplicationRecord
  belongs_to :volunteer_profile
  has_one_attached :document

  validates :name, presence: true

  scope :expiring_within, ->(days) { where(expires_at: Date.current..days.days.from_now) }
  scope :expired, -> { where("expires_at < ?", Date.current) }

  def expiring_soon?(days = 30)
    expires_at.present? && expires_at <= days.days.from_now
  end

  def expired?
    expires_at.present? && expires_at < Date.current
  end
end
