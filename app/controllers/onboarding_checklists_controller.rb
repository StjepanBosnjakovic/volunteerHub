class OnboardingChecklistsController < ApplicationController
  include Pagy::Backend

  before_action :set_checklist, only: %i[show edit update destroy]

  def index
    authorize OnboardingChecklist
    @pagy, @checklists = pagy(policy_scope(OnboardingChecklist).includes(:onboarding_steps))
  end

  def show
    authorize @checklist
    @steps = @checklist.onboarding_steps

    if current_user.role_volunteer? && current_user.volunteer_profile.present?
      @progress = build_progress_map(current_user.volunteer_profile)
    end
  end

  def new
    authorize OnboardingChecklist
    @checklist = OnboardingChecklist.new
    @checklist.onboarding_steps.build
  end

  def create
    authorize OnboardingChecklist
    @checklist = OnboardingChecklist.new(checklist_params)
    @checklist.organisation = current_user.organisation

    if @checklist.save
      redirect_to @checklist, notice: "Checklist created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @checklist
  end

  def update
    authorize @checklist

    if @checklist.update(checklist_params)
      redirect_to @checklist, notice: "Checklist updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @checklist
    @checklist.destroy
    redirect_to onboarding_checklists_path, notice: "Checklist deleted."
  end

  def cohort_dashboard
    authorize OnboardingChecklist, :index?
    @checklists = policy_scope(OnboardingChecklist).includes(onboarding_steps: :volunteer_onboarding_progresses)
  end

  private

  def set_checklist
    @checklist = policy_scope(OnboardingChecklist).find(params[:id])
  end

  def build_progress_map(volunteer_profile)
    progresses = volunteer_profile.volunteer_onboarding_progresses
                                   .joins(:onboarding_step)
                                   .where(onboarding_steps: { onboarding_checklist_id: @checklist.id })
                                   .index_by(&:onboarding_step_id)
    @checklist.onboarding_steps.each_with_object({}) do |step, hash|
      hash[step.id] = progresses[step.id]
    end
  end

  def checklist_params
    params.require(:onboarding_checklist).permit(
      :title, :description, :target_role, :active,
      onboarding_steps_attributes: [:id, :step_type, :title, :description, :content_url, :position, :_destroy]
    )
  end
end
