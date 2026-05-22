class SetupController < ApplicationController
  skip_before_action :check_setup_complete

  def details
    @organisation = current_user.organisation
  end

  def update_details
    @organisation = current_user.organisation
    if @organisation.update(details_params)
      redirect_to setup_branding_path
    else
      render :details, status: :unprocessable_entity
    end
  end

  def branding
    @organisation = current_user.organisation
  end

  def update_branding
    @organisation = current_user.organisation
    if @organisation.update(branding_params)
      redirect_to setup_team_path
    else
      render :branding, status: :unprocessable_entity
    end
  end

  def team
  end

  def invite_team
    emails = params[:emails].to_s.split(/[\s,\n]+/).map(&:strip).reject(&:blank?)

    emails.each do |email|
      next if User.exists?(email: email)
      user = User.new(
        email: email,
        role: :coordinator,
        organisation: current_user.organisation,
        password: SecureRandom.hex(20)
      )
      user.skip_confirmation! if Rails.env.development?
      user.save && user.send_reset_password_instructions
    end

    redirect_to setup_done_path
  end

  def done
  end

  def finish
    current_user.organisation.update_column(:setup_complete, true)
    redirect_to dashboard_path, notice: "#{current_user.organisation.name} is all set! Welcome to VolunteerOS."
  end

  private

  def details_params
    params.require(:organisation).permit(:name, :slug, :timezone)
  end

  def branding_params
    params.require(:organisation).permit(:logo, :primary_colour)
  end
end
