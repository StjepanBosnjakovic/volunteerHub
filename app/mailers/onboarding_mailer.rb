class OnboardingMailer < ActionMailer::Base
  layout "mailer"

  def stall_reminder(volunteer_profile, checklist)
    @volunteer = volunteer_profile
    @checklist = checklist
    org = checklist.organisation
    sender = org.email_sender_address.presence ? "#{org.email_sender_name} <#{org.email_sender_address}>" : "VolunteerOS <noreply@volunteeros.app>"
    mail(
      from: sender,
      to: @volunteer.user.email,
      subject: "Don't forget to complete your onboarding — #{checklist.title}"
    )
  end
end
