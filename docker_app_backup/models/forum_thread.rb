class ForumThread < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :user
  belongs_to :forum_category, counter_cache: true
  has_many :forum_replies, dependent: :destroy
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: %w[draft published locked archived] }
  
  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :locked, -> { where(locked: true) }
  scope :unlocked, -> { where(locked: false) }
  scope :pinned, -> { where(pinned: true) }
  scope :recent, -> { order(updated_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  
  # Enums
  enum status: { draft: 0, published: 1, locked: 2, archived: 3 }
  
  # Methods
  def latest_reply
    forum_replies.recent.first
  end
  
  def latest_activity
    [updated_at, forum_replies.maximum(:created_at)].compact.max
  end
  
  def replies_count
    forum_replies.count
  end
  
  def participants
    User.joins(:forum_replies)
        .where(forum_replies: { forum_thread: self })
        .distinct
        .includes(:forum_replies)
  end
  
  def participants_count
    participants.count
  end
  
  def can_reply?
    published? && !locked?
  end
  
  def locked?
    super || status == 'locked'
  end
  
  def user_participated?(user)
    return false unless user
    
    user == self.user || forum_replies.exists?(user: user)
  end
  
  def mark_as_read_by(user)
    return unless user
    
    # Implementation for read tracking would go here
    # Could use a separate ForumThreadRead model
  end
  
  def should_generate_new_friendly_id?
    title_changed? || super
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("title ILIKE ? OR content ILIKE ?", "%#{term}%", "%#{term}%")
  end
  
  # Callbacks
  after_create :update_category_counters
  after_destroy :update_category_counters
  
  private
  
  def update_category_counters
    forum_category.touch
  end
end