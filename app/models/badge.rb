class Badge < ApplicationRecord
  acts_as_tenant :organisation, optional: true  # nil organisation = system-wide badge

  belongs_to :organisation, optional: true
  has_many :volunteer_badges, dependent: :destroy
  has_many :volunteer_profiles, through: :volunteer_badges
  has_one_attached :artwork

  CRITERIA_TYPES = %w[hours_reached milestone consecutive_months manual].freeze

  validates :name, presence: true
  validates :criteria_type, presence: true, inclusion: { in: CRITERIA_TYPES }
  validates :criteria_value, numericality: { greater_than: 0 }, allow_nil: true

  scope :system_badges, -> { where(organisation_id: nil) }
  scope :org_badges,    -> { where.not(organisation_id: nil) }
  scope :ordered,       -> { order(:name) }

  def system_badge?
    organisation_id.nil?
  end

  def auto_awardable?
    criteria_type != "manual"
  end
end
