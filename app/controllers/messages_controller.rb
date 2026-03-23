class MessagesController < ApplicationController
  before_action :set_conversation

  def create
    authorize Message
    @message = @conversation.messages.new(sender: current_user, message_type: :text)
    @message.body = params.dig(:message, :body)

    if @message.save
      @conversation.mark_read_for!(current_user)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/form",
            locals:  { conversation: @conversation, message: @message }
          )
        end
        format.html { redirect_to @conversation, alert: "Message could not be sent." }
      end
    end
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])
  end
end
