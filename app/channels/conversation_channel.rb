class ConversationChannel < ApplicationCable::Channel
  def subscribed
    @conversation = current_user.conversations.find(params[:conversation_id])
    stream_for @conversation
    
    # Mark user as online in this conversation
    update_presence(true)
  end

  def unsubscribed
    update_presence(false) if @conversation
  end

  def speak(data)
    @conversation = current_user.conversations.find(params[:conversation_id])
    
    message_params = {
      user: current_user,
      content: data['content'],
      message_type: data['message_type'] || 'text'
    }
    
    # Add reply_to if provided
    if data['reply_to_message_id'].present?
      message_params[:reply_to_message_id] = data['reply_to_message_id']
    end
    
    message = @conversation.messages.create!(message_params)

    # Broadcast typing stopped
    broadcast_typing_status(false)
  end

  def start_typing
    broadcast_typing_status(true)
  end

  def stop_typing
    broadcast_typing_status(false)
  end

  def mark_as_read(data)
    message = Message.find(data['message_id'])
    message.mark_as_read_by(current_user)
    
    # Update last_read_at for user_conversation
    user_conversation = current_user.user_conversations.find_by(conversation: @conversation)
    user_conversation&.update(last_read_at: Time.current)
  end

  private

  def update_presence(online)
    ConversationChannel.broadcast_to(
      @conversation,
      {
        type: 'presence_update',
        user_id: current_user.id,
        online: online
      }
    )
  end

  def broadcast_typing_status(typing)
    ConversationChannel.broadcast_to(
      @conversation,
      {
        type: 'typing_indicator',
        user_id: current_user.id,
        username: current_user.name,
        typing: typing
      }
    )
  end
end