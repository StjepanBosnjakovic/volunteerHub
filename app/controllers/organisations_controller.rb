class OrganisationsController < ApplicationController
  before_action :set_organisation

  def show
    authorize @organisation
  end

  def edit
    authorize @organisation, :settings?
  end

  def update
    authorize @organisation, :update?

    if @organisation.update(organisation_params)
      respond_to do |format|
        format.html { redirect_to organisation_path, notice: "Settings updated." }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organisation
    @organisation = current_user.organisation
  end

  def organisation_params
    params.require(:organisation).permit(
      :name, :primary_colour, :timezone, :locale,
      :email_sender_name, :email_sender_address, :logo
    )
  end
end
