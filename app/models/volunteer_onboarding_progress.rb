class VolunteerOnboardingProgress < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :onboarding_step

  validates :volunteer_profile, presence: true
  validates :onboarding_step, presence: true
  validates :volunteer_profile_id, uniqueness: { scope: :onboarding_step_id }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def completed?
    completed_at.present?
  end

  def complete!
    update!(completed_at: Time.current)
  end
end
