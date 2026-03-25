class BadgesController < ApplicationController
  include Pagy::Method

  before_action :set_badge, only: %i[show edit update destroy]

  def index
    authorize Badge
    @pagy, @badges = pagy(policy_scope(Badge).ordered, items: 30)
  end

  def show
    authorize @badge
  end

  def new
    authorize Badge
    @badge = Badge.new
  end

  def create
    authorize Badge
    @badge = Badge.new(badge_params)
    @badge.organisation = current_user.organisation

    if @badge.save
      redirect_to badges_path, notice: "Badge created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @badge
  end

  def update
    authorize @badge

    if @badge.update(badge_params)
      redirect_to badge_path(@badge), notice: "Badge updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @badge
    @badge.destroy
    redirect_to badges_path, notice: "Badge deleted."
  end

  private

  def set_badge
    @badge = policy_scope(Badge).find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :criteria_type, :criteria_value, :artwork)
  end
end
