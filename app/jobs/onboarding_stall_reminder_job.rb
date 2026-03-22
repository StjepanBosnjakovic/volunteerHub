class OnboardingStallReminderJob < ApplicationJob
  queue_as :default

  STALL_DAYS = 3

  def perform
    OnboardingChecklist.active.each do |checklist|
      stalled_profiles(checklist).each do |profile|
        OnboardingMailer.stall_reminder(profile, checklist).deliver_later
      end
    end
  end

  private

  def stalled_profiles(checklist)
    step_ids = checklist.onboarding_steps.pluck(:id)
    return [] if step_ids.empty?

    # Find profiles that have started but not completed all steps
    # and haven't made progress in STALL_DAYS days
    stall_cutoff = STALL_DAYS.days.ago

    started_profiles = VolunteerOnboardingProgress
      .where(onboarding_step_id: step_ids)
      .where(completed_at: ..stall_cutoff)
      .select(:volunteer_profile_id)
      .distinct
      .pluck(:volunteer_profile_id)

    completed_all = VolunteerOnboardingProgress
      .where(onboarding_step_id: step_ids)
      .where.not(completed_at: nil)
      .group(:volunteer_profile_id)
      .having("COUNT(*) = ?", step_ids.count)
      .pluck(:volunteer_profile_id)

    stalled_ids = started_profiles - completed_all
    VolunteerProfile.where(id: stalled_ids).includes(:user)
  end
end
