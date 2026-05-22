class OnboardingController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_application_by_token
  before_action :ensure_not_already_complete, only: %i[show set_password submit_info complete_step finish]

  def show
  end

  def set_password
    user = @application.volunteer_profile.user

    unless user.reset_password_token.present?
      redirect_to onboard_path(@token), alert: "This setup link is no longer valid." and return
    end

    if user.reset_password(params[:password], params[:password_confirmation])
      user.update_column(:reset_password_token, nil)
      sign_in(user)
      redirect_to onboard_path(@token), notice: "Password set. Continue your onboarding below."
    else
      @password_errors = user.errors.full_messages
      render :show, status: :unprocessable_entity
    end
  end

  def submit_info
    @onboarding_questions.each do |question|
      answer_params = params.dig(:answers, question.id.to_s)
      next if answer_params.blank?

      existing = @application.application_answers.find_or_initialize_by(application_question: question)
      existing.value = answer_params[:value]
      existing.save
    end

    redirect_to onboard_path(@token), notice: "Information saved."
  end

  def complete_step
    step = @checklist_steps.find_by(id: params[:step_id])
    return redirect_to onboard_path(@token) unless step

    profile = @application.volunteer_profile
    return redirect_to onboard_path(@token) unless profile

    VolunteerOnboardingProgress.find_or_create_by!(
      volunteer_profile: profile,
      onboarding_step: step
    ) do |p|
      p.completed_at = Time.current
    end.tap do |p|
      p.update_column(:completed_at, Time.current) if p.completed_at.nil?
    end

    redirect_to onboard_path(@token), notice: "Step marked complete."
  end

  def finish
    @application.update_column(:onboarding_completed_at, Time.current)

    if user_signed_in?
      redirect_to dashboard_path, notice: "Onboarding complete! Welcome."
    else
      redirect_to new_user_session_path, notice: "Onboarding complete! Sign in to access your dashboard."
    end
  end

  private

  def set_application_by_token
    @token = params[:token]
    @application = VolunteerApplication.find_by(onboarding_token: @token)

    unless @application
      render plain: "Invalid or expired onboarding link.", status: :not_found and return
    end

    @opportunity = @application.opportunity
    @checklist = @opportunity.onboarding_checklist
    @checklist_steps = @checklist&.onboarding_steps || OnboardingStep.none
    @onboarding_questions = @opportunity.onboarding_questions

    if @application.volunteer_profile.present?
      @progress = @checklist_steps.index_with do |step|
        VolunteerOnboardingProgress.find_by(
          volunteer_profile: @application.volunteer_profile,
          onboarding_step: step
        )
      end
      @answered = @application.application_answers
                               .where(application_question: @onboarding_questions)
                               .index_by(&:application_question_id)
    else
      @progress = {}
      @answered = {}
    end
  end

  def ensure_not_already_complete
    if @application.onboarding_complete?
      if user_signed_in?
        redirect_to dashboard_path, notice: "You have already completed onboarding."
      else
        redirect_to new_user_session_path, notice: "You have already completed onboarding. Please sign in."
      end
    end
  end
end
