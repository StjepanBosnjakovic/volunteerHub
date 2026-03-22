class VolunteerProfilesController < ApplicationController
  include Pagy::Backend

  before_action :set_volunteer_profile, only: [:show, :edit, :update, :destroy, :archive]

  def index
    authorize VolunteerProfile
    @pagy, @volunteer_profiles = pagy(
      policy_scope(VolunteerProfile).includes(:user, :skills, :interest_categories)
        .order(:last_name, :first_name)
    )
  end

  def show
    authorize @volunteer_profile
  end

  def new
    authorize VolunteerProfile
    @volunteer_profile = VolunteerProfile.new
    @volunteer_profile.emergency_contacts.build
  end

  def create
    authorize VolunteerProfile
    @volunteer_profile = VolunteerProfile.new(volunteer_profile_params)
    @volunteer_profile.user = current_user unless current_user.admin?
    @volunteer_profile.organisation = current_user.organisation

    if @volunteer_profile.save
      redirect_to @volunteer_profile, notice: "Profile created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @volunteer_profile
  end

  def update
    authorize @volunteer_profile

    if @volunteer_profile.update(volunteer_profile_params)
      respond_to do |format|
        format.html { redirect_to @volunteer_profile, notice: "Profile updated successfully." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("volunteer_profile", partial: "volunteer_profiles/profile", locals: { volunteer_profile: @volunteer_profile }) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @volunteer_profile
    @volunteer_profile.destroy
    redirect_to volunteer_profiles_path, notice: "Profile deleted."
  end

  def archive
    authorize @volunteer_profile, :archive?
    @volunteer_profile.update(status: :inactive)
    redirect_to @volunteer_profile, notice: "Profile archived."
  end

  def export_csv
    authorize VolunteerProfile, :export_csv?
    @volunteer_profiles = policy_scope(VolunteerProfile).includes(:user, :skills)

    respond_to do |format|
      format.csv do
        send_data generate_csv(@volunteer_profiles),
                  filename: "volunteers-#{Date.current}.csv",
                  type: "text/csv"
      end
    end
  end

  private

  def set_volunteer_profile
    @volunteer_profile = policy_scope(VolunteerProfile).find(params[:id])
  end

  def volunteer_profile_params
    params.require(:volunteer_profile).permit(
      :first_name, :last_name, :preferred_name, :pronouns, :date_of_birth,
      :phone, :bio, :status, :max_hours_per_week, :max_hours_per_month,
      :policy_accepted_at, :avatar,
      skill_ids: [],
      interest_category_ids: [],
      emergency_contacts_attributes: [:id, :name, :relationship, :phone, :email, :_destroy],
      availabilities_attributes: [:id, :day_of_week, :time_blocks, :_destroy]
    )
  end

  def generate_csv(profiles)
    require "csv"
    CSV.generate(headers: true) do |csv|
      csv << ["First Name", "Last Name", "Email", "Phone", "Status", "Skills", "Date of Birth"]
      profiles.each do |p|
        csv << [p.first_name, p.last_name, p.user.email, p.phone, p.status, p.skills.map(&:name).join(", "), p.date_of_birth]
      end
    end
  end
end
