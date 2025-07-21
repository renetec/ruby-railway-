class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :user
  has_many_attached :images
  
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :condition, presence: true
  validates :status, inclusion: { in: %w[draft active sold archived] }
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_condition, ->(condition) { where(condition: condition) }
  scope :by_price_range, ->(min, max) { where(price: min..max) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  
  # Enums
  enum status: { draft: 0, active: 1, sold: 2, archived: 3 }
  enum condition: { 
    new_item: 0, 
    like_new: 1, 
    good: 2, 
    fair: 3, 
    poor: 4 
  }
  
  # Categories
  CATEGORIES = %w[
    electronics
    furniture
    clothing
    books
    sports
    home_garden
    automotive
    toys_games
    collectibles
    services
    other
  ].freeze
  
  # Methods
  def formatted_price
    "$#{price.to_f}"
  end
  
  def condition_badge_class
    case condition
    when 'new_item' then 'bg-green-100 text-green-800'
    when 'like_new' then 'bg-blue-100 text-blue-800'
    when 'good' then 'bg-yellow-100 text-yellow-800'
    when 'fair' then 'bg-orange-100 text-orange-800'
    when 'poor' then 'bg-red-100 text-red-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
  
  def main_image
    images.attached? ? images.first : nil
  end
  
  def available?
    active?
  end
  
  def mark_as_sold!
    update!(status: 'sold', sold_at: Time.current)
  end
  
  def should_generate_new_friendly_id?
    name_changed? || super
  end
  
  # Search scope
  scope :search_by_term, ->(term) do
    return all if term.blank?
    
    where("name ILIKE ? OR description ILIKE ? OR location ILIKE ?", 
          "%#{term}%", "%#{term}%", "%#{term}%")
  end
end