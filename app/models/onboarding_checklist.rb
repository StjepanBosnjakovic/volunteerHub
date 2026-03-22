class OnboardingChecklist < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :onboarding_steps, -> { order(:position) }, dependent: :destroy

  validates :title, presence: true

  scope :active, -> { where(active: true) }

  def completion_rate_for_cohort
    return 0 if onboarding_steps.empty?

    total_steps = onboarding_steps.count
    profiles_with_progress = VolunteerOnboardingProgress
      .joins(:onboarding_step)
      .where(onboarding_steps: { onboarding_checklist_id: id })
      .where.not(completed_at: nil)
      .select(:volunteer_profile_id)
      .distinct

    return 0 if profiles_with_progress.empty?

    avg_completions = profiles_with_progress.map do |profile|
      VolunteerOnboardingProgress
        .joins(:onboarding_step)
        .where(onboarding_steps: { onboarding_checklist_id: id })
        .where(volunteer_profile_id: profile.volunteer_profile_id)
        .where.not(completed_at: nil)
        .count
    end.sum.to_f / profiles_with_progress.count

    (avg_completions / total_steps * 100).round
  end
end
