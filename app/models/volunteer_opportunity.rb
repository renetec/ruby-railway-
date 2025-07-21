class VolunteerOpportunity < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Associations
  belongs_to :user
  belongs_to :organization, class_name: 'Business', optional: true
  has_many :volunteer_applications, dependent: :destroy
  has_many :volunteers, through: :volunteer_applications, source: :user
  has_many_attached :images
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 50 }
  validates :category, presence: true
  validates :time_commitment, presence: true
  validates :status, inclusion: { in: %w[draft active closed archived] }
  validates :volunteers_needed, numericality: { greater_than: 0 }, allow_blank: true
  
  # Custom validations
  validate :end_date_after_start_date
  validate :application_deadline_validation
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_time_commitment, ->(commitment) { where(time_commitment: commitment) }
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :remote, -> { where(remote: true) }
  scope :urgent, -> { where(urgent: true) }
  scope :featured, -> { where(featured: true) }
  scope :with_spots_available, -> { where('volunteers_needed IS NULL OR volunteers_needed > current_volunteers') }
  
  # Enums
  enum status: { draft: 0, active: 1, closed: 2, archived: 3 }
  enum time_commitment: {
    one_time: 0,
    weekly: 1,
    monthly: 2,
    seasonal: 3,
    ongoing: 4,
    flexible: 5
  }
  
  # Categories
  CATEGORIES = %w[
    community_service
    education
    environment
    healthcare
    animals
    seniors
    youth
    homeless
    food_security
    disaster_relief
    arts_culture
    sports_recreation
    technology
    advocacy
    fundraising
    other
  ].freeze
  
  # Methods
  def volunteers_count
    volunteer_applications.accepted.count
  end
  
  def pending_applications_count
    volunteer_applications.pending.count
  end
  
  def spots_remaining
    return Float::INFINITY unless volunteers_needed.present?
    
    volunteers_needed - volunteers_count
  end
  
  def full?
    return false unless volunteers_needed.present?
    
    spots_remaining <= 0
  end
  
  def user_applied?(user)
    return false unless user
    
    volunteer_applications.exists?(user: user)
  end
  
  def can_apply?
    active? && !expired? && !full?
  end
  
  def deadline_approaching?
    return false unless application_deadline.present?
    
    application_deadline <= 7.days.from_now
  end
  
  def expired?
    return false unless application_deadline.present?
    
    application_deadline < Time.current
  end
  
  def duration_display
    return "Ongoing" unless start_date.present?
    return start_date.strftime("%B %d, %Y") unless end_date.present?
    
    "#{start_date.strftime('%B %d, %Y')} - #{end_date.strftime('%B %d, %Y')}"
  end
  
  def organization_name
    organization&.name || "Independent Volunteer"
  end
  
  def location_display
    return "Remote" if remote?
    return location if location.present?
    
    organization&.full_address || "Location TBD"
  end
  
  def should_generate_new_friendly_id?
    title_changed? || super
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    left_joins(:organization).where(
      "volunteer_opportunities.title ILIKE ? OR volunteer_opportunities.description ILIKE ? OR volunteer_opportunities.location ILIKE ? OR businesses.name ILIKE ?", 
      "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
    )
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end
  
  def application_deadline_validation
    return unless application_deadline.present?
    
    if application_deadline <= Time.current
      errors.add(:application_deadline, "must be in the future")
    end
  end
end