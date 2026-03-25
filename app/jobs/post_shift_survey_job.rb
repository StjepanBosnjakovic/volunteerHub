# Runs after a shift ends (+ grace period).
# Finds post_shift surveys for the organisation and sends them to all
# confirmed volunteers who attended the shift.
class PostShiftSurveyJob < ApplicationJob
  queue_as :default

  def perform(shift_id)
    shift = Shift.find_by(id: shift_id)
    return unless shift

    ActsAsTenant.with_tenant(shift.program.organisation) do
      surveys = Survey.active.post_shift
      return if surveys.empty?

      attendees = shift.shift_assignments
                       .where(status: :confirmed)
                       .includes(volunteer_profile: :user)
                       .map(&:volunteer_profile)

      surveys.each do |survey|
        attendees.each do |profile|
          # Skip if already responded
          next if survey.survey_responses.exists?(volunteer_profile: profile)

          SurveyMailer.post_shift_survey(profile, survey, shift).deliver_later

          Rails.logger.info "[PostShiftSurveyJob] Survey '#{survey.title}' sent to " \
                            "volunteer_profile=#{profile.id} for shift=#{shift_id}"
        end
      end
    end
  end
end
