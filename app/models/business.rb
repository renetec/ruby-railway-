class Business < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :business_reviews, dependent: :destroy
  has_many_attached :images
  has_one_attached :logo
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :category, presence: true
  validates :status, inclusion: { in: %w[draft active inactive archived] }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/ }, allow_blank: true
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_location, ->(location) { where("address ILIKE ? OR city ILIKE ?", "%#{location}%", "%#{location}%") }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :alphabetical, -> { order(:name) }
  scope :with_jobs, -> { joins(:jobs).where(jobs: { status: 'active' }).distinct }
  
  # Enums
  enum status: { draft: 0, active: 1, inactive: 2, archived: 3 }
  
  # Categories
  CATEGORIES = %w[
    restaurant
    retail
    healthcare
    technology
    education
    professional_services
    automotive
    beauty_wellness
    construction
    real_estate
    finance
    entertainment
    nonprofit
    government
    other
  ].freeze
  
  # Methods
  def full_address
    [address, city, state, zip_code].compact.join(', ')
  end
  
  def has_location?
    address.present? || city.present?
  end
  
  def contact_info
    [email, phone, website].compact
  end
  
  def active_jobs_count
    jobs.active.count
  end
  
  def average_rating
    return 0 if business_reviews.empty?
    
    business_reviews.average(:rating).to_f.round(1)
  end
  
  def reviews_count
    business_reviews.count
  end
  
  def main_image
    logo.attached? ? logo : (images.attached? ? images.first : nil)
  end
  
  def should_generate_new_friendly_id?
    name_changed? || super
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("name ILIKE ? OR description ILIKE ? OR address ILIKE ? OR city ILIKE ?", 
          "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  end
  
  # Validation methods
  def validate_website_format
    return unless website.present?
    
    unless website.match?(/\Ahttps?:\/\//)
      self.website = "http://#{website}"
    end
  end
  
  before_save :validate_website_format
end