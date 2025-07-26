class Job < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :business
  has_many :job_applications, dependent: :destroy
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 50 }
  validates :job_type, presence: true
  validates :experience_level, presence: true
  validates :status, inclusion: { in: %w[draft active closed archived] }
  validates :salary_min, numericality: { greater_than: 0 }, allow_blank: true
  validates :salary_max, numericality: { greater_than: 0 }, allow_blank: true
  
  # Custom validations
  validate :salary_range_validation
  validate :application_deadline_validation
  
  # Callbacks
  after_create :enqueue_translation_job
  after_update :enqueue_translation_job, if: :saved_change_to_title_or_description?
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_job_type, ->(type) { where(job_type: type) }
  scope :by_experience_level, ->(level) { where(experience_level: level) }
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :remote, -> { where(remote: true) }
  scope :with_salary, -> { where.not(salary_min: nil, salary_max: nil) }
  scope :urgent, -> { where(urgent: true) }
  scope :featured, -> { where(featured: true) }
  
  # Enums
  enum status: { draft: 0, active: 1, closed: 2, archived: 3 }
  enum job_type: { 
    full_time: 0, 
    part_time: 1, 
    contract: 2, 
    temporary: 3, 
    internship: 4,
    volunteer: 5
  }
  enum experience_level: {
    entry_level: 0,
    mid_level: 1,
    senior_level: 2,
    executive: 3,
    no_experience: 4
  }
  
  # Methods
  def salary_range_display
    return "Salary not specified" if salary_min.blank? && salary_max.blank?
    return "$#{salary_min.to_i}+" if salary_min.present? && salary_max.blank?
    return "Up to $#{salary_max.to_i}" if salary_min.blank? && salary_max.present?
    
    "$#{salary_min.to_i} - $#{salary_max.to_i}"
  end
  
  def applications_count
    job_applications.count
  end
  
  def deadline_approaching?
    return false unless application_deadline.present?
    
    application_deadline <= 7.days.from_now
  end
  
  def expired?
    return false unless application_deadline.present?
    
    application_deadline < Time.current
  end
  
  def can_apply?
    active? && !expired?
  end
  
  def user_applied?(user)
    return false unless user
    
    job_applications.exists?(user: user)
  end
  
  def location_display
    return "Remote" if remote?
    return location if location.present?
    
    business.full_address
  end
  
  def company_name
    business.name
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
  
  def translated_requirements(locale = I18n.locale)
    return requirements unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return requirements if locale == original_language
    
    translations.dig(locale, 'requirements') || requirements
  end
  
  def translate_content!
    LibreTranslateService.translate_job_content(self)
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    joins(:business).where(
      "jobs.title ILIKE ? OR jobs.description ILIKE ? OR jobs.location ILIKE ? OR businesses.name ILIKE ?", 
      "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
    )
  end
  
  private
  
  def salary_range_validation
    return unless salary_min.present? && salary_max.present?
    
    if salary_min >= salary_max
      errors.add(:salary_max, "must be greater than minimum salary")
    end
  end
  
  def application_deadline_validation
    return unless application_deadline.present?
    
    if application_deadline <= Time.current
      errors.add(:application_deadline, "must be in the future")
    end
  end
  
  def enqueue_translation_job
    return unless respond_to?(:original_language) && respond_to?(:translations)
    ContentTranslationJob.perform_later(self)
  end
  
  def saved_change_to_title_or_description?
    saved_change_to_title? || saved_change_to_description? || saved_change_to_requirements?
  end
end