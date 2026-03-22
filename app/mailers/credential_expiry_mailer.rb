class CredentialExpiryMailer < ApplicationMailer
  def alert(credential, days_until_expiry)
    @credential = credential
    @volunteer = credential.volunteer_profile
    @user = @volunteer.user
    @days = days_until_expiry

    mail(
      to: @user.email,
      subject: "Credential expiring in #{days_until_expiry} days: #{credential.name}"
    )
  end
end
