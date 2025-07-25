class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :user
  has_many_attached :images
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :category, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }
  
  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }
  
  # Enums
  enum status: { draft: 0, published: 1, archived: 2 }
  
  # Categories
  CATEGORIES = %w[
    news
    events
    community
    business
    technology
    lifestyle
    health
    education
    sports
    culture
  ].freeze
  
  # Methods
  def excerpt(limit = 150)
    content.truncate(limit)
  end
  
  def reading_time
    words_per_minute = 200
    word_count = content.split.size
    (word_count / words_per_minute.to_f).ceil
  end
  
  def published?
    status == 'published'
  end
  
  def should_generate_new_friendly_id?
    title_changed? || super
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("title ILIKE ? OR content ILIKE ?", "%#{term}%", "%#{term}%")
  end
end