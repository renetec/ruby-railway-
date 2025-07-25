class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :user
  has_many :event_rsvps, dependent: :destroy
  has_many :attendees, through: :event_rsvps, source: :user
  has_many_attached :images
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :date, presence: true
  validates :location, length: { maximum: 255 }, allow_blank: true
  validates :capacity, numericality: { greater_than: 0 }, allow_blank: true
  validates :status, inclusion: { in: %w[draft published cancelled] }
  
  # Custom validations
  validate :date_cannot_be_in_the_past, on: :create
  validate :capacity_not_exceeded
  
  # Callbacks
  after_create :enqueue_translation_job
  after_update :enqueue_translation_job, if: :saved_change_to_title_or_description?
  
  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :upcoming, -> { where('date > ?', Time.current) }
  scope :past, -> { where('date < ?', Time.current) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :with_availability, -> { where('capacity > rsvp_count') }
  
  # Enums
  enum status: { draft: 0, published: 1, cancelled: 2 }
  enum category: {
    community: 0,
    business: 1,
    education: 2,
    entertainment: 3,
    sports: 4,
    health: 5,
    technology: 6,
    culture: 7,
    volunteer: 8,
    other: 9
  }
  
  # Methods
  def spots_remaining
    return nil unless capacity.present?
    capacity - rsvp_count
  end
  
  def full?
    return false unless capacity.present?
    spots_remaining <= 0
  end
  
  def user_attending?(user)
    event_rsvps.exists?(user: user)
  end
  
  def past_event?
    date < Time.current
  end
  
  def upcoming_event?
    date > Time.current
  end
  
  def can_rsvp?
    published? && upcoming_event? && !full?
  end
  
  def increment_rsvp_count!
    increment!(:rsvp_count)
  end
  
  def decrement_rsvp_count!
    decrement!(:rsvp_count)
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
  
  def translated_description(locale = I18n.locale)
    return description unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return description if locale == original_language
    
    translations.dig(locale, 'description') || description
  end
  
  def translated_location(locale = I18n.locale)
    return location unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return location if locale == original_language
    
    translations.dig(locale, 'location') || location
  end
  
  def translate_content!
    LibreTranslateService.translate_event_content(self)
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("title ILIKE ? OR description ILIKE ? OR location ILIKE ?", "%#{term}%", "%#{term}%", "%#{term}%")
  end
  
  private
  
  def date_cannot_be_in_the_past
    return unless date.present? && date < Time.current
    
    errors.add(:date, "can't be in the past")
  end
  
  def capacity_not_exceeded
    return unless capacity.present? && rsvp_count > capacity
    
    errors.add(:capacity, "cannot be less than current RSVP count")
  end
  
  def enqueue_translation_job
    return unless respond_to?(:original_language) && respond_to?(:translations)
    EventTranslationJob.perform_later(self)
  end
  
  def saved_change_to_title_or_description?
    saved_change_to_title? || saved_change_to_description? || saved_change_to_location?
  end
end