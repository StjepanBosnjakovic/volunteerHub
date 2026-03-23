class VolunteerApplicationsController < ApplicationController
  include Pagy::Method

  skip_before_action :authenticate_user!, only: %i[new create]

  before_action :set_opportunity
  before_action :set_application, only: %i[show update destroy]

  def index
    authorize VolunteerApplication
    @applications = policy_scope(VolunteerApplication)
      .where(opportunity: @opportunity)
      .includes(:volunteer_profile)
      .ordered_by_position
  end

  def kanban
    authorize VolunteerApplication, :index?
    @by_status = VolunteerApplication.statuses.keys.index_with do |status|
      @opportunity.volunteer_applications
                  .where(status: status)
                  .includes(volunteer_profile: :user)
                  .ordered_by_position
    end
  end

  def show
    authorize @application
  end

  def new
    @application = VolunteerApplication.new
    @questions = @opportunity.application_questions
  end

  def create
    @application = VolunteerApplication.new(opportunity: @opportunity)

    if user_signed_in? && current_user.volunteer_profile.present?
      @application.volunteer_profile = current_user.volunteer_profile
    else
      redirect_to new_user_session_path, alert: "Please sign in or create an account to apply."
      return
    end

    build_answers

    if @application.save
      VolunteerApplicationMailer.confirmation(@application).deliver_later
      respond_to do |format|
        format.html { redirect_to opportunity_path(@opportunity), notice: "Application submitted!" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "application_status",
            partial: "volunteer_applications/status_badge",
            locals: { application: @application }
          )
        end
      end
    else
      @questions = @opportunity.application_questions
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @application

    if params[:volunteer_application][:status].present?
      old_status = @application.status
      @application.update(status: params[:volunteer_application][:status],
                          position: params[:volunteer_application][:position])
      VolunteerApplicationMailer.status_changed(@application, old_status).deliver_later if @application.status != old_status

      respond_to do |format|
        format.html { redirect_to opportunity_kanban_path(@opportunity), notice: "Application updated." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("application_#{@application.id}",
                                 partial: "volunteer_applications/card",
                                 locals: { application: @application }),
            turbo_stream.update("spot_count_#{@opportunity.id}",
                                html: @opportunity.reload.spots_remaining.to_s)
          ]
        end
      end
    end
  end

  def destroy
    authorize @application
    @application.destroy
    redirect_to opportunity_kanban_path(@opportunity), notice: "Application removed."
  end

  def bulk_update
    authorize VolunteerApplication, :update?

    ids = params[:application_ids] || []
    new_status = params[:status]
    applications = @opportunity.volunteer_applications.where(id: ids)

    applications.each do |app|
      old_status = app.status
      app.update(status: new_status)
      VolunteerApplicationMailer.status_changed(app, old_status).deliver_later
    end

    respond_to do |format|
      format.html { redirect_to opportunity_kanban_path(@opportunity), notice: "#{applications.count} applications updated." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "kanban_board",
          partial: "volunteer_applications/kanban_board",
          locals: { by_status: reload_kanban }
        )
      end
    end
  end

  private

  def set_opportunity
    if user_signed_in?
      ActsAsTenant.with_tenant(current_user.organisation) do
        @opportunity = Opportunity.find_by!(slug: params[:opportunity_id])
      end
    else
      @opportunity = Opportunity.published.find_by!(slug: params[:opportunity_id])
    end
  end

  def set_application
    @application = @opportunity.volunteer_applications.find(params[:id])
  end

  def build_answers
    @opportunity.application_questions.each do |question|
      answer_params = params.dig(:answers, question.id.to_s)
      next if answer_params.blank?

      answer = @application.application_answers.build(application_question: question)
      if question.question_type == "file"
        answer.file_upload = answer_params[:file_upload] if answer_params[:file_upload].present?
      else
        answer.value = answer_params[:value]
      end
    end
  end

  def reload_kanban
    VolunteerApplication.statuses.keys.index_with do |status|
      @opportunity.volunteer_applications
                  .where(status: status)
                  .includes(volunteer_profile: :user)
                  .ordered_by_position
    end
  end
end
