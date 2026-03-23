# Runs after an HourLog is approved.
# Compares the volunteer's cumulative approved hours against all org Milestones
# and creates VolunteerMilestone records for any newly crossed thresholds.
class MilestoneCheckJob < ApplicationJob
  queue_as :default

  def perform(volunteer_profile_id)
    profile = VolunteerProfile.find_by(id: volunteer_profile_id)
    return unless profile

    ActsAsTenant.with_tenant(profile.organisation) do
      total = profile.hour_logs.approved.sum(:hours)

      profile.organisation.milestones.ordered.each do |milestone|
        next if total < milestone.threshold_hours
        next if profile.volunteer_milestones.exists?(milestone: milestone)

        profile.volunteer_milestones.create!(
          milestone:  milestone,
          reached_at: Time.current
        )

        Rails.logger.info "[MilestoneCheckJob] Milestone '#{milestone.label}' reached " \
                          "by volunteer_profile=#{volunteer_profile_id}"
        # Phase 5 will send a congratulations notification here
      end
    end
  end
end
