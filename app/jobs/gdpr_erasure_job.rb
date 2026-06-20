class GdprErasureJob < ApplicationJob
  queue_as :low

  def perform(volunteer_profile_id)
    profile = VolunteerProfile.find_by(id: volunteer_profile_id)
    return unless profile

    profile.anonymize!
    Rails.logger.info "GDPR erasure completed for VolunteerProfile##{volunteer_profile_id}"
  end
end
