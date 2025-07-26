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
  
  # Callbacks
  after_create :enqueue_translation_job
  after_update :enqueue_translation_job, if: :saved_change_to_title_or_content?
  
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
  
  # Translation methods
  def translated_title(locale = I18n.locale)
    return title unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return title if locale == original_language
    
    translations.dig(locale, 'title') || title
  end
  
  def translated_content(locale = I18n.locale)
    return content unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return content if locale == original_language
    
    translations.dig(locale, 'content') || content
  end
  
  def translate_content!
    LibreTranslateService.translate_post_content(self)
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("title ILIKE ? OR content ILIKE ?", "%#{term}%", "%#{term}%")
  end
  
  private
  
  def enqueue_translation_job
    return unless respond_to?(:original_language) && respond_to?(:translations)
    ContentTranslationJob.perform_later(self)
  end
  
  def saved_change_to_title_or_content?
    saved_change_to_title? || saved_change_to_content?
  end
end