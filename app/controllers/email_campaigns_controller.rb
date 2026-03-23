class EmailCampaignsController < ApplicationController
  before_action :set_campaign, only: %i[show edit update destroy send_campaign]

  def index
    authorize EmailCampaign
    @campaigns = policy_scope(EmailCampaign).ordered
  end

  def show
    authorize @campaign
  end

  def new
    authorize EmailCampaign
    @campaign = EmailCampaign.new
    @programs = policy_scope(Program).ordered
  end

  def create
    authorize EmailCampaign
    @campaign = EmailCampaign.new(campaign_params)
    @campaign.organisation = current_user.organisation
    @campaign.sender       = current_user

    if @campaign.save
      redirect_to email_campaign_path(@campaign), notice: "Campaign saved as draft."
    else
      @programs = policy_scope(Program).ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @campaign
    @programs = policy_scope(Program).ordered
  end

  def update
    authorize @campaign

    if @campaign.update(campaign_params)
      redirect_to email_campaign_path(@campaign), notice: "Campaign updated."
    else
      @programs = policy_scope(Program).ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @campaign
    @campaign.destroy
    redirect_to email_campaigns_path, notice: "Campaign deleted."
  end

  def send_campaign
    authorize @campaign, :send_campaign?

    recipient_preview = @campaign.update(campaign_params.merge(status: :sending))
    BroadcastMessageJob.perform_later(@campaign.id, "campaign")
    redirect_to email_campaign_path(@campaign), notice: "Campaign is being sent."
  end

  def preview_segment
    authorize EmailCampaign, :create?
    filters = params.permit(:role, :program_id, :volunteer_status).to_h
    temp = BroadcastMessage.new(
      organisation:    current_user.organisation,
      segment_filters: filters,
      sender:          current_user,
      subject:         "preview",
      body:            "preview",
      channel:         :in_app
    )
    @count = temp.resolve_recipients.count

    render json: { count: @count }
  end

  private

  def set_campaign
    @campaign = policy_scope(EmailCampaign).find(params[:id])
  end

  def campaign_params
    params.require(:email_campaign).permit(
      :name, :subject_a, :subject_b, :body_html, :channel,
      :scheduled_at,
      segment_filters: [:role, :program_id, :volunteer_status]
    )
  end
end
