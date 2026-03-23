class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[show]

  def index
    authorize Conversation
    @conversations = policy_scope(Conversation).for_user(current_user)
                                               .includes(:participants, messages: :sender)
                                               .ordered
  end

  def show
    authorize @conversation
    @messages = @conversation.messages.ordered.includes(:sender, :rich_text_body)
    @conversation.mark_read_for!(current_user)
    @message = Message.new
  end

  def new
    authorize Conversation
    @users = policy_scope(User).where.not(id: current_user.id).order(:email)
  end

  def create
    authorize Conversation

    if params[:conversation_type] == "direct"
      recipient = User.find(params[:recipient_id])
      @conversation = Conversation.find_or_create_direct(
        current_user, recipient, current_user.organisation
      )
      redirect_to @conversation
    else
      @conversation = Conversation.new(conversation_params)
      @conversation.organisation = current_user.organisation

      if @conversation.save
        @conversation.conversation_participants.create!(user: current_user)
        Array(params[:participant_ids]).each do |uid|
          @conversation.conversation_participants.find_or_create_by!(user_id: uid)
        end
        redirect_to @conversation, notice: "Group conversation created."
      else
        @users = policy_scope(User).where.not(id: current_user.id).order(:email)
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def set_conversation
    @conversation = policy_scope(Conversation).for_user(current_user).find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:title, :conversation_type)
  end
end
