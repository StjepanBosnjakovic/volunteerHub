class PromoteWaitlistJob < ApplicationJob
  queue_as :default

  def perform(application_id)
    application = VolunteerApplication.find_by(id: application_id)
    return unless application
    return unless application.waitlisted?
    return if application.opportunity.full?

    application.update!(status: :shortlisted)
    VolunteerApplicationMailer.status_changed(application, "waitlisted").deliver_later
  end
end
