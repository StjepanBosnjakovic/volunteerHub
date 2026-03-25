class ReferencesController < ApplicationController
  include Pagy::Method

  before_action :set_volunteer_profile
  before_action :set_reference, only: %i[show issue decline export_pdf]

  def index
    authorize Reference
    @pagy, @references = pagy(
      policy_scope(Reference).where(volunteer_profile: @volunteer_profile).ordered,
      items: 20
    )
  end

  def show
    authorize @reference
  end

  def new
    authorize Reference
    @reference = @volunteer_profile.references.build
  end

  def create
    authorize Reference
    @reference = @volunteer_profile.references.build(reference_params)
    @reference.coordinator = current_user

    if @reference.save
      redirect_to volunteer_profile_reference_path(@volunteer_profile, @reference),
                  notice: "Reference request submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def issue
    authorize @reference, :issue?
    @reference.issue!(coordinator: current_user)
    redirect_to volunteer_profile_reference_path(@volunteer_profile, @reference),
                notice: "Reference issued."
  end

  def decline
    authorize @reference, :decline?
    @reference.update!(status: :declined)
    redirect_to volunteer_profile_references_path(@volunteer_profile),
                notice: "Reference request declined."
  end

  def export_pdf
    authorize @reference, :show?
    pdf = ReferencePdfService.new(@reference).render
    send_data pdf,
              filename:    "reference_#{@reference.id}.pdf",
              type:        "application/pdf",
              disposition: "inline"
  end

  private

  def set_volunteer_profile
    @volunteer_profile = VolunteerProfile.find(params[:volunteer_profile_id])
  end

  def set_reference
    @reference = @volunteer_profile.references.find(params[:id])
  end

  def reference_params
    params.require(:reference).permit(:notes)
  end
end
