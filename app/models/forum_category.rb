class ForumCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :forum_threads, dependent: :destroy
  has_many :forum_replies, through: :forum_threads
  
  # Validations
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :position, presence: true, numericality: { greater_than: 0 }
  
  # Scopes
  scope :visible, -> { where(visible: true) }
  scope :ordered, -> { order(:position, :name) }
  scope :with_threads, -> { joins(:forum_threads).distinct }
  
  # Methods
  def latest_thread
    forum_threads.published.recent.first
  end
  
  def latest_reply
    forum_replies.recent.first
  end
  
  def threads_count
    forum_threads.published.count
  end
  
  def replies_count
    forum_replies.count
  end
  
  def should_generate_new_friendly_id?
    name_changed? || super
  end
end