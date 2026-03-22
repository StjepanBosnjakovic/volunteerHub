class VolunteerApplicationMailer < ActionMailer::Base
  layout "mailer"

  def confirmation(application)
    @application = application
    @opportunity = application.opportunity
    @volunteer = application.volunteer_profile
    org = @opportunity.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    mail(
      from: sender,
      to: @volunteer.user.email,
      subject: "Application received: #{@opportunity.title}"
    )
  end

  def status_changed(application, previous_status)
    @application = application
    @opportunity = application.opportunity
    @volunteer = application.volunteer_profile
    @previous_status = previous_status
    org = @opportunity.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    mail(
      from: sender,
      to: @volunteer.user.email,
      subject: "Your application status has been updated — #{@opportunity.title}"
    )
  end
end
