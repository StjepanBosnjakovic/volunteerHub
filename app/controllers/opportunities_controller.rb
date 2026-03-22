class OpportunitiesController < ApplicationController
  include Pagy::Backend

  # Allow public access to index/show/embed
  skip_before_action :authenticate_user!, only: %i[index show embed]

  before_action :set_opportunity, only: %i[show edit update destroy publish close embed]

  def index
    @opportunities = base_scope
    @opportunities = filter_opportunities(@opportunities)
    @pagy, @opportunities = pagy(@opportunities, items: 12)
  end

  def show
    content_for :title, "#{@opportunity.title} — VolunteerOS"
    content_for :head do
      render_to_string partial: "opportunities/seo_tags", locals: { opportunity: @opportunity }
    end
  end

  def embed
    render layout: "embed"
  end

  def new
    authorize Opportunity
    @opportunity = Opportunity.new
    @opportunity.application_questions.build
  end

  def create
    authorize Opportunity
    @opportunity = Opportunity.new(opportunity_params)
    @opportunity.organisation = current_user.organisation

    if @opportunity.save
      redirect_to @opportunity, notice: "Opportunity created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @opportunity
  end

  def update
    authorize @opportunity

    if @opportunity.update(opportunity_params)
      redirect_to @opportunity, notice: "Opportunity updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @opportunity
    @opportunity.destroy
    redirect_to opportunities_path, notice: "Opportunity deleted."
  end

  def publish
    authorize @opportunity, :update?
    @opportunity.update(status: :published)
    redirect_to @opportunity, notice: "Opportunity published."
  end

  def close
    authorize @opportunity, :update?
    @opportunity.update(status: :closed)
    redirect_to @opportunity, notice: "Opportunity closed."
  end

  private

  def set_opportunity
    scope = if user_signed_in?
      ActsAsTenant.with_tenant(current_user.organisation) { Opportunity.all }
    else
      Opportunity.published
    end
    @opportunity = scope.find_by!(slug: params[:id])
  end

  def base_scope
    if user_signed_in?
      policy_scope(Opportunity).includes(:skills, :organisation)
    else
      Opportunity.published.includes(:skills)
    end.order(:starts_at)
  end

  def filter_opportunities(scope)
    scope = scope.where(category: params[:category]) if params[:category].present?
    scope = scope.where("starts_at >= ?", Date.parse(params[:from])) if params[:from].present?
    scope = scope.where("starts_at <= ?", Date.parse(params[:to])) if params[:to].present?
    scope = scope.where(commitment_level: params[:commitment_level]) if params[:commitment_level].present?
    scope = scope.joins(:skills).where(skills: { id: params[:skill_id] }) if params[:skill_id].present?
    scope
  end

  def opportunity_params
    params.require(:opportunity).permit(
      :title, :description, :location, :lat, :lng, :starts_at, :ends_at,
      :spots_available, :commitment_level, :status, :category,
      skill_ids: [],
      application_questions_attributes: [:id, :question_type, :label, :options, :position, :required, :_destroy]
    )
  end
end
