class SurveysController < ApplicationController
  include Pagy::Method

  before_action :set_survey, only: %i[show edit update destroy dashboard]

  def index
    authorize Survey
    @pagy, @surveys = pagy(policy_scope(Survey).ordered, items: 20)
  end

  def show
    authorize @survey
  end

  def new
    authorize Survey
    @survey = Survey.new(questions: default_questions)
  end

  def create
    authorize Survey
    @survey = Survey.new(survey_params)
    @survey.organisation = current_user.organisation

    if @survey.save
      redirect_to survey_path(@survey), notice: "Survey created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @survey
  end

  def update
    authorize @survey

    if @survey.update(survey_params)
      redirect_to survey_path(@survey), notice: "Survey updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @survey
    @survey.destroy
    redirect_to surveys_path, notice: "Survey deleted."
  end

  def dashboard
    authorize @survey, :show?

    @total_responses  = @survey.survey_responses.count
    @nps_score        = @survey.net_promoter_score
    @average_nps      = @survey.average_nps
    @recent_responses = @survey.survey_responses.recent.limit(10).includes(:volunteer_profile)

    # Monthly response counts for trend chart (last 6 months)
    @monthly_counts = @survey.survey_responses
                              .where("created_at >= ?", 6.months.ago)
                              .group("DATE_TRUNC('month', created_at)")
                              .order("DATE_TRUNC('month', created_at)")
                              .count
  end

  private

  def set_survey
    @survey = policy_scope(Survey).find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:title, :trigger, :active, :grace_period_hours,
                                   questions: [:type, :label, options: []])
  end

  def default_questions
    [
      { "type" => "nps", "label" => "How likely are you to recommend volunteering with us? (0-10)" },
      { "type" => "text", "label" => "What did you enjoy most about your experience?" }
    ]
  end
end
