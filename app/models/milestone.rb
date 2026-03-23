class Milestone < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :volunteer_milestones, dependent: :destroy

  validates :label, presence: true
  validates :threshold_hours, presence: true,
    numericality: { greater_than: 0 }
  validates :threshold_hours, uniqueness: { scope: :organisation_id,
    message: "already has a milestone at that threshold" }

  scope :ordered, -> { order(:threshold_hours) }
end
