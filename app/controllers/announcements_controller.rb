class AnnouncementsController < ApplicationController
  include Pagy::Methods

  before_action :set_announcement, only: %i[show edit update destroy publish schedule_send]

  def index
    authorize Announcement
    scope = policy_scope(Announcement)

    if current_user.admin?
      @pagy, @announcements = pagy(scope.ordered, items: 20)
    else
      @pagy, @announcements = pagy(scope.visible.ordered, items: 20)
    end
  end

  def show
    authorize @announcement
  end

  def new
    authorize Announcement
    @announcement = Announcement.new
  end

  def create
    authorize Announcement
    @announcement = Announcement.new(announcement_params)
    @announcement.organisation = current_user.organisation
    @announcement.author       = current_user

    if @announcement.save
      redirect_to announcements_path, notice: "Announcement saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @announcement
  end

  def update
    authorize @announcement

    if @announcement.update(announcement_params)
      redirect_to announcement_path(@announcement), notice: "Announcement updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @announcement
    @announcement.destroy
    redirect_to announcements_path, notice: "Announcement deleted."
  end

  def publish
    authorize @announcement, :publish?
    @announcement.publish!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "announcement_#{@announcement.id}",
          partial: "announcements/announcement_row",
          locals:  { announcement: @announcement }
        )
      end
      format.html { redirect_to announcements_path, notice: "Announcement published." }
    end
  end

  def schedule_send
    authorize @announcement, :publish?
    scheduled_at = Time.zone.parse(params[:scheduled_for])

    if scheduled_at && scheduled_at > Time.current
      @announcement.schedule!(at: scheduled_at)
      AnnouncementPublishJob.set(wait_until: scheduled_at).perform_later(@announcement.id)
      redirect_to announcements_path, notice: "Announcement scheduled for #{scheduled_at.strftime('%d %b at %H:%M')}."
    else
      redirect_to announcements_path, alert: "Please provide a valid future date."
    end
  end

  private

  def set_announcement
    @announcement = policy_scope(Announcement).find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:title, :body, :status, :scheduled_for)
  end
end
