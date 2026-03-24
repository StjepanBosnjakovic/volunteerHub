class SurveyMailer < ApplicationMailer
  def post_shift_survey(volunteer_profile, survey, shift)
    @volunteer_profile = volunteer_profile
    @survey            = survey
    @shift             = shift
    @survey_url        = survey_survey_responses_url(@survey, shift_id: @shift.id)

    mail(
      to:      volunteer_profile.user.email,
      subject: "Share your feedback: #{shift.title}"
    )
  end
end
