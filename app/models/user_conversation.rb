class UserConversation < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
  
  # Validations
  validates :user_id, uniqueness: { scope: :conversation_id }
  
  # Scopes
  scope :admins, -> { where(is_admin: true) }
  scope :active, -> { where(left_at: nil) }
  
  def admin?
    is_admin?
  end
  
  def active?
    left_at.nil?
  end
end