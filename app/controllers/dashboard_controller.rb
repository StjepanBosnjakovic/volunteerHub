class DashboardController < ApplicationController
  def index
    @organisation = current_user.organisation
    @total_volunteers = policy_scope(VolunteerProfile).count
    @active_volunteers = policy_scope(VolunteerProfile).status_active.count
    @pending_volunteers = policy_scope(VolunteerProfile).status_pending.count
    @expiring_credentials = Credential.joins(:volunteer_profile)
                                      .where(volunteer_profiles: { organisation: @organisation })
                                      .expiring_within(30).count
  end
end
