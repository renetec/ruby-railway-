class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :check_conversation_access

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to @conversation }
        format.json { render json: { success: true, message: @message } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @conversation, alert: 'Message could not be sent.' }
        format.json { render json: { success: false, errors: @message.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message = @conversation.messages.find(params[:id])
    message_id = @message.id
    
    # Allow any conversation participant to delete any message
    @message.destroy
    
    # Broadcast the deletion using the stored ID
    ConversationChannel.broadcast_to(
      @conversation,
      {
        type: 'message_deleted',
        message_id: message_id
      }
    )
    head :ok
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def check_conversation_access
    unless @conversation.users.include?(current_user)
      redirect_to conversations_path, alert: 'You do not have access to this conversation.'
    end
  end

  def message_params
    params.require(:message).permit(:content, :reply_to_message_id, images: [])
  end
end