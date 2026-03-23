class Program < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :shifts, dependent: :destroy
  has_many :hour_logs, dependent: :destroy
  has_many :coordinator_programs, foreign_key: :programme_id, dependent: :destroy
  has_many :coordinators, through: :coordinator_programs, source: :user

  validates :name, presence: true, uniqueness: { scope: :organisation_id }
  validates :organisation, presence: true

  scope :ordered, -> { order(:name) }

  def coordinator?(user)
    return true if user.role_super_admin?
    coordinators.include?(user)
  end
end
