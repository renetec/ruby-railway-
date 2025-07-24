class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :update, :destroy]

  def index
    @conversations = current_user.conversations
                                .includes(:users, :messages)
                                .joins(:user_conversations)
                                .where(user_conversations: { user: current_user, left_at: nil })
                                .order('conversations.updated_at DESC')
                                .page(params[:page])
                                .per(20)

    @unread_counts = calculate_unread_counts(@conversations)
  end

  def show
    @messages = @conversation.messages
                            .includes(:user, images_attachments: :blob, file_attachment: :blob)
                            .order(:created_at)
                            .page(params[:page])
                            .per(50)

    # Mark messages as read
    mark_conversation_as_read
  end

  def create
    if params[:user_ids].present?
      # Group conversation
      @conversation = create_group_conversation
    elsif params[:other_user_id].present?
      # Private conversation
      @conversation = find_or_create_private_conversation
      
      # If there's an initial message (from product inquiry), create it
      if @conversation.persisted? && params[:initial_message].present?
        message = @conversation.messages.build(
          user: current_user,
          content: params[:initial_message]
        )
        unless message.save
          Rails.logger.error "Failed to save initial message: #{message.errors.full_messages}"
        end
      end
    else
      render json: { error: 'Invalid parameters' }, status: :unprocessable_entity
      return
    end

    if @conversation.persisted?
      if request.format.json?
        render json: { 
          conversation_id: @conversation.id, 
          message: 'Conversation created successfully' 
        }
      else
        redirect_to @conversation
      end
    else
      if request.format.json?
        render json: { errors: @conversation.errors }, status: :unprocessable_entity
      else
        render json: { errors: @conversation.errors }, status: :unprocessable_entity
      end
    end
  end

  def update
    if @conversation.update(conversation_params)
      broadcast_conversation_update
      render json: { status: 'updated' }
    else
      render json: { errors: @conversation.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow leaving conversation for group chats, or hide for direct messages
    user_conversation = current_user.user_conversations.find_by(conversation: @conversation)
    
    if @conversation.group_chat?
      # For group chats, mark user as left
      user_conversation&.update(left_at: Time.current)
      redirect_to conversations_path, notice: 'Left conversation successfully'
    else
      # For direct messages, just redirect back (can't really "delete" a DM)
      redirect_to conversations_path, notice: 'Conversation archived'
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:name, user_ids: [])
  end

  def create_group_conversation
    ActiveRecord::Base.transaction do
      conversation = Conversation.create!(
        name: params[:name],
        conversation_type: 'group_chat',
        created_by: current_user
      )

      # Add creator as admin
      conversation.user_conversations.create!(user: current_user, is_admin: true)

      # Add other users
      User.where(id: params[:user_ids]).find_each do |user|
        conversation.user_conversations.create!(user: user)
      end

      conversation
    end
  end

  def find_or_create_private_conversation
    other_user = User.find(params[:other_user_id])
    
    # Try to find existing direct conversation between these users
    existing = Conversation.direct_message
                          .joins(:user_conversations)
                          .where(user_conversations: { user: [current_user, other_user] })
                          .group('conversations.id')
                          .having('COUNT(user_conversations.id) = 2')
                          .first

    return existing if existing

    # Create new direct conversation
    ActiveRecord::Base.transaction do
      conversation = Conversation.create!(
        conversation_type: 'direct_message',
        created_by: current_user
      )

      conversation.user_conversations.create!([
        { user: current_user },
        { user: other_user }
      ])

      conversation
    end
  end

  def mark_conversation_as_read
    user_conversation = current_user.user_conversations.find_by(conversation: @conversation)
    user_conversation&.update(last_read_at: Time.current)
  end

  def calculate_unread_counts(conversations)
    conversations.each_with_object({}) do |conversation, hash|
      hash[conversation.id] = conversation.unread_count_for(current_user)
    end
  end
  
  def broadcast_conversation_update
    ConversationChannel.broadcast_to(
      @conversation,
      {
        type: 'conversation_update',
        conversation: {
          id: @conversation.id,
          name: @conversation.name
        }
      }
    )
  end
end