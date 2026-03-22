class Skill < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :volunteer_skills, dependent: :destroy
  has_many :volunteer_profiles, through: :volunteer_skills

  validates :name, presence: true, uniqueness: { scope: :organisation_id }

  scope :alphabetical, -> { order(:name) }
end
