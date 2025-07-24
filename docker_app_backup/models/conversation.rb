class Conversation < ApplicationRecord
  # Associations
  has_many :user_conversations, dependent: :destroy
  has_many :users, through: :user_conversations
  has_many :messages, dependent: :destroy
  has_one_attached :avatar # For group conversations
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  
  # Enums
  enum conversation_type: { direct_message: 0, group_chat: 1 }
  
  # Validations
  validates :name, presence: true, if: :group_chat?
  # validate :must_have_at_least_two_users # Comment out for now
  
  # Scopes
  scope :with_unread_for, ->(user) { 
    joins(:user_conversations)
      .where(user_conversations: { user: user })
      .where('user_conversations.last_read_at < conversations.updated_at OR user_conversations.last_read_at IS NULL')
  }
  
  def last_message
    messages.order(:created_at).last
  end
  
  def unread_count_for(user)
    user_conversation = user_conversations.find_by(user: user)
    return 0 unless user_conversation
    
    messages.where('created_at > ?', user_conversation.last_read_at || user_conversation.created_at).count
  end
  
  def active_members
    users.joins(:user_conversations)
         .where(user_conversations: { conversation: self, left_at: nil })
  end

  def admins
    active_members.where(user_conversations: { is_admin: true })
  end
  
  private
  
  def must_have_at_least_two_users
    errors.add(:base, 'Must have at least 2 participants') if user_conversations.count < 2
  end
end