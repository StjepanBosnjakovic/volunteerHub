class BroadcastMessagesController < ApplicationController
  before_action :set_broadcast, only: %i[show edit update destroy send_broadcast]

  def index
    authorize BroadcastMessage
    @broadcasts = policy_scope(BroadcastMessage).ordered
  end

  def show
    authorize @broadcast
  end

  def new
    authorize BroadcastMessage
    @broadcast = BroadcastMessage.new
    @programs  = policy_scope(Program).ordered
  end

  def create
    authorize BroadcastMessage
    @broadcast = BroadcastMessage.new(broadcast_params)
    @broadcast.organisation = current_user.organisation
    @broadcast.sender       = current_user

    if @broadcast.save
      redirect_to broadcast_message_path(@broadcast), notice: "Broadcast saved."
    else
      @programs = policy_scope(Program).ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @broadcast
    @programs = policy_scope(Program).ordered
  end

  def update
    authorize @broadcast

    if @broadcast.update(broadcast_params)
      redirect_to broadcast_message_path(@broadcast), notice: "Broadcast updated."
    else
      @programs = policy_scope(Program).ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @broadcast
    @broadcast.destroy
    redirect_to broadcast_messages_path, notice: "Broadcast deleted."
  end

  def send_broadcast
    authorize @broadcast, :send_broadcast?
    @broadcast.send_broadcast!
    redirect_to broadcast_message_path(@broadcast), notice: "Broadcast is being sent to recipients."
  end

  def preview_segment
    authorize BroadcastMessage, :create?

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

  def set_broadcast
    @broadcast = policy_scope(BroadcastMessage).find(params[:id])
  end

  def broadcast_params
    params.require(:broadcast_message).permit(
      :subject, :body, :channel,
      segment_filters: [:role, :program_id, :volunteer_status]
    )
  end
end
