class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  belongs_to :reply_to, class_name: 'Message', foreign_key: 'reply_to_message_id', optional: true
  has_many :replies, class_name: 'Message', foreign_key: 'reply_to_message_id'
  
  # Active Storage for media
  has_many_attached :images
  has_one_attached :file
  
  # Enums
  enum message_type: { text: 0, image: 1, file: 2, system: 3 }
  enum delivery_status: { sent: 0, delivered: 1, read: 2 }
  
  # Validations
  validates :content, presence: true, unless: :has_attachments?
  validates :user, presence: true
  validates :conversation, presence: true
  
  # Callbacks
  after_create_commit :broadcast_to_conversation
  after_update_commit :broadcast_status_update
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unread_for, ->(user) { where('created_at > ?', user.user_conversations.find_by(conversation: conversation)&.last_read_at || created_at) }
  
  def has_attachments?
    images.any? || file.attached?
  end
  
  def mark_as_read_by(user)
    read_by_list = self.read_by || []
    unless read_by_list.include?(user.id)
      read_by_list << user.id
      update_column(:read_by, read_by_list)
    end
  end
  
  private
  
  def broadcast_to_conversation
    Rails.logger.info "Broadcasting message from user #{user.id} to conversation #{conversation.id}"
    ConversationChannel.broadcast_to(
      conversation,
      {
        type: 'new_message',
        message: ApplicationController.render(
          partial: 'messages/message',
          locals: { message: self, current_user: nil }
        ),
        sender_id: user.id,
        sender_name: user.name,
        message_content: content
      }
    )
    Rails.logger.info "Message broadcast completed"
  rescue => e
    Rails.logger.error "Message broadcast failed: #{e.message}"
  end
  
  def broadcast_status_update
    if delivery_status_previously_changed?
      ConversationChannel.broadcast_to(
        conversation,
        {
          type: 'message_status_update',
          message_id: id,
          status: delivery_status
        }
      )
    end
  end
end