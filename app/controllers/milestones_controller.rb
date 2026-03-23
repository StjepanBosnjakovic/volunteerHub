class MilestonesController < ApplicationController
  before_action :set_milestone, only: %i[show edit update destroy]

  def index
    authorize Milestone
    @milestones = policy_scope(Milestone).ordered
  end

  def show
    authorize @milestone
  end

  def new
    authorize Milestone
    @milestone = Milestone.new
  end

  def create
    authorize Milestone
    @milestone = Milestone.new(milestone_params)
    @milestone.organisation = current_user.organisation

    if @milestone.save
      redirect_to milestones_path, notice: "Milestone created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @milestone
  end

  def update
    authorize @milestone
    if @milestone.update(milestone_params)
      redirect_to milestones_path, notice: "Milestone updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @milestone
    @milestone.destroy
    redirect_to milestones_path, notice: "Milestone deleted."
  end

  private

  def set_milestone
    @milestone = policy_scope(Milestone).find(params[:id])
  end

  def milestone_params
    params.require(:milestone).permit(:label, :threshold_hours, :message)
  end
end
