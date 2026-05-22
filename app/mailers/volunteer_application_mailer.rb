class VolunteerApplicationMailer < ActionMailer::Base
  layout "mailer"

  def confirmation(application)
    @application = application
    @opportunity = application.opportunity
    @volunteer = application.volunteer_profile
    @guest_name = application.guest_name
    org = @opportunity.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    recipient = @volunteer ? @volunteer.user.email : application.guest_email
    mail(from: sender, to: recipient, subject: "Application received: #{@opportunity.title}")
  end

  def status_changed(application, previous_status)
    @application = application
    @opportunity = application.opportunity
    @volunteer = application.volunteer_profile
    @previous_status = previous_status
    org = @opportunity.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    recipient = @volunteer ? @volunteer.user.email : application.guest_email
    mail(from: sender, to: recipient, subject: "Your application status has been updated — #{@opportunity.title}")
  end

  def approved_invite(application, reset_token)
    @application = application
    @opportunity = application.opportunity
    @guest_name = application.guest_name
    @reset_token = reset_token
    @onboarding_url = onboard_url(application.onboarding_token)
    org = @opportunity.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    mail(from: sender, to: application.guest_email, subject: "You've been approved — #{@opportunity.title}")
  end
end
