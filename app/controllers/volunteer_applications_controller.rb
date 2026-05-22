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
      @application.guest_name = params[:guest_name]
      @application.guest_email = params[:guest_email]
    end

    build_answers

    if @application.save
      create_pending_guest_profile(@application) if @application.guest_email.present?
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
  rescue ActiveRecord::RecordNotUnique
    @questions = @opportunity.application_questions
    @application.errors.add(:base, "You have already applied to this opportunity.")
    render :new, status: :unprocessable_entity
  end

  def update
    authorize @application

    if params[:volunteer_application][:status].present?
      old_status = @application.status
      @application.update(status: params[:volunteer_application][:status],
                          position: params[:volunteer_application][:position])

      if @application.status != old_status
        if @application.status == "approved"
          if @application.guest_email.present?
            link_or_invite_guest(@application)
          else
            @application.generate_onboarding_token!
            VolunteerApplicationMailer.status_changed(@application.reload, old_status).deliver_later
          end
        else
          VolunteerApplicationMailer.status_changed(@application, old_status).deliver_later
        end
      end

      respond_to do |format|
        format.html { redirect_to kanban_opportunity_path(@opportunity), notice: "Application updated." }
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
    redirect_to kanban_opportunity_path(@opportunity), notice: "Application removed."
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
      format.html { redirect_to kanban_opportunity_path(@opportunity), notice: "#{applications.count} applications updated." }
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

  def create_pending_guest_profile(application)
    org = application.opportunity.organisation
    email = application.guest_email
    name_parts = application.guest_name.to_s.split
    first_name = name_parts.first || "Volunteer"
    last_name = name_parts.drop(1).join(" ").presence || first_name

    existing_user = ActsAsTenant.without_tenant { User.find_by(email: email, organisation: org) }

    if existing_user
      profile = existing_user.volunteer_profile || ActsAsTenant.with_tenant(org) {
        VolunteerProfile.create!(user: existing_user, organisation: org,
                                 first_name: first_name, last_name: last_name, status: :pending)
      }
    else
      new_user = ActsAsTenant.with_tenant(org) {
        User.create!(email: email, organisation: org, role: :volunteer, password: SecureRandom.hex(16))
      }
      new_user.confirm
      profile = ActsAsTenant.with_tenant(org) {
        VolunteerProfile.create!(user: new_user, organisation: org,
                                 first_name: first_name, last_name: last_name, status: :pending)
      }
    end

    application.update_column(:volunteer_profile_id, profile.id)
  end

  def link_or_invite_guest(application)
    profile = application.volunteer_profile

    unless profile
      create_pending_guest_profile(application)
      profile = application.reload.volunteer_profile
    end

    profile.update_column(:status, VolunteerProfile.statuses[:active])

    application.generate_onboarding_token!

    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    profile.user.update_columns(reset_password_token: hashed, reset_password_sent_at: Time.current)
    VolunteerApplicationMailer.approved_invite(application.reload, raw).deliver_later
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
