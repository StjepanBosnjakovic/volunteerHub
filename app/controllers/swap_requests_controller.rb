class SwapRequestsController < ApplicationController
  before_action :set_swap_request, only: %i[show approve decline]

  def index
    authorize SwapRequest
    @swap_requests = policy_scope(SwapRequest).pending_review
      .includes(from_assignment: [:shift, :volunteer_profile])
  end

  def show
    authorize @swap_request
  end

  def create
    authorize SwapRequest
    assignment = ShiftAssignment.find(params[:from_assignment_id])
    @swap_request = SwapRequest.new(
      from_assignment: assignment,
      requested_by: current_user,
      notes: params[:notes]
    )

    if @swap_request.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash_messages",
            partial: "shared/flash", locals: { notice: "Swap request submitted." })
        end
        format.html do
          redirect_back fallback_location: root_path, notice: "Swap request submitted."
        end
      end
    else
      redirect_back fallback_location: root_path, alert: "Could not submit swap request."
    end
  end

  def approve
    authorize @swap_request
    @swap_request.approve!(current_user)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("swap_request_#{@swap_request.id}")
      end
      format.html { redirect_to swap_requests_path, notice: "Swap approved." }
    end
  end

  def decline
    authorize @swap_request
    @swap_request.decline!(current_user)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("swap_request_#{@swap_request.id}")
      end
      format.html { redirect_to swap_requests_path, notice: "Swap declined." }
    end
  end

  private

  def set_swap_request
    @swap_request = policy_scope(SwapRequest).find(params[:id])
  end
end
