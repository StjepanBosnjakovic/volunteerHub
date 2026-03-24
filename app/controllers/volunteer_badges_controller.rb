class VolunteerBadgesController < ApplicationController
  before_action :set_volunteer_profile

  def create
    authorize VolunteerBadge
    badge = Badge.find(params[:badge_id])

    @volunteer_badge = @volunteer_profile.volunteer_badges.build(
      badge:      badge,
      awarded_by: current_user,
      awarded_at: Time.current
    )

    if @volunteer_badge.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "volunteer_badges_#{@volunteer_profile.id}",
            partial: "volunteer_badges/badge_card",
            locals:  { volunteer_badge: @volunteer_badge }
          )
        end
        format.html { redirect_to volunteer_profile_path(@volunteer_profile), notice: "Badge awarded." }
      end
    else
      redirect_to volunteer_profile_path(@volunteer_profile),
                  alert: @volunteer_badge.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize VolunteerBadge
    @volunteer_badge = @volunteer_profile.volunteer_badges.find(params[:id])
    @volunteer_badge.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("volunteer_badge_#{@volunteer_badge.id}")
      end
      format.html { redirect_to volunteer_profile_path(@volunteer_profile), notice: "Badge removed." }
    end
  end

  private

  def set_volunteer_profile
    @volunteer_profile = VolunteerProfile.find(params[:volunteer_profile_id])
  end
end
