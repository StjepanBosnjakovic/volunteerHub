class MessagesChannel < ActionCable::Channel::Base
  def subscribed
    conversation = find_conversation
    if conversation
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Cleanup on disconnect
  end

  def receive(data)
    conversation = find_conversation
    return unless conversation

    message = conversation.messages.create!(
      sender:       current_user,
      message_type: :text
    )

    message.body = data["body"]
    message.save!
  end

  private

  def find_conversation
    return nil unless params[:conversation_id]

    Conversation.for_user(current_user).find_by(id: params[:conversation_id])
  end
end
