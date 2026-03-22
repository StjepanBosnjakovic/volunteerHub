class OnboardingProgressesController < ApplicationController
  before_action :set_step
  before_action :set_checklist

  def create
    @progress = VolunteerOnboardingProgress.find_or_initialize_by(
      volunteer_profile: current_user.volunteer_profile,
      onboarding_step: @step
    )

    if @step.quiz_step? && @step.quiz.present?
      handle_quiz_submission
    else
      @progress.complete!
      respond_with_progress_update
    end
  end

  private

  def set_step
    @step = OnboardingStep.find(params[:onboarding_step_id])
  end

  def set_checklist
    @checklist = @step.onboarding_checklist
  end

  def handle_quiz_submission
    quiz = @step.quiz
    answers_params = params[:quiz_answers] || {}

    quiz.quiz_questions.each do |question|
      answer = QuizAnswer.find_or_initialize_by(
        volunteer_profile: current_user.volunteer_profile,
        quiz_question: question
      )
      submitted_answer = answers_params[question.id.to_s]
      answer.answer = submitted_answer
      answer.correct = submitted_answer.to_s.strip.downcase == question.correct_answer.strip.downcase
      answer.save!
    end

    score = quiz.score_for(current_user.volunteer_profile)
    passed = quiz.passed_by?(current_user.volunteer_profile)
    @progress.complete! if passed

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "step_#{@step.id}_status",
            partial: "onboarding_checklists/step_status",
            locals: { step: @step, progress: @progress, checklist: @checklist }
          ),
          turbo_stream.replace(
            "quiz_result_#{@step.id}",
            partial: "onboarding_checklists/quiz_result",
            locals: { score: score, passed: passed, passing_score: quiz.passing_score }
          ),
          turbo_stream.replace(
            "progress_bar",
            partial: "onboarding_checklists/progress_bar",
            locals: { checklist: @checklist, volunteer_profile: current_user.volunteer_profile }
          )
        ]
      end
      format.html { redirect_to onboarding_checklist_path(@checklist) }
    end
  end

  def respond_with_progress_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "step_#{@step.id}_status",
            partial: "onboarding_checklists/step_status",
            locals: { step: @step, progress: @progress, checklist: @checklist }
          ),
          turbo_stream.replace(
            "progress_bar",
            partial: "onboarding_checklists/progress_bar",
            locals: { checklist: @checklist, volunteer_profile: current_user.volunteer_profile }
          )
        ]
      end
      format.html { redirect_to onboarding_checklist_path(@checklist) }
    end
  end
end
