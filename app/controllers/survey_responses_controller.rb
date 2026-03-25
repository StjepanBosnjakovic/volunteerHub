class SurveyResponsesController < ApplicationController
  before_action :set_survey

  def new
    authorize SurveyResponse
    @survey_response = SurveyResponse.new
    @shift = params[:shift_id].present? ? Shift.find_by(id: params[:shift_id]) : nil
  end

  def create
    authorize SurveyResponse
    @survey_response = @survey.survey_responses.build(survey_response_params)
    @survey_response.volunteer_profile = current_user.volunteer_profile
    @survey_response.shift_id = params[:survey_response][:shift_id].presence

    if @survey_response.save
      redirect_to survey_path(@survey), notice: "Thank you for your feedback!"
    else
      @shift = @survey_response.shift
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def survey_response_params
    params.require(:survey_response).permit(answers: {})
  end
end
