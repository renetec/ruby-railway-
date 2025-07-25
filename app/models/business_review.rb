class BusinessReview < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :business
  
  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :business_id, message: "has already reviewed this business" }
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :positive, -> { where(rating: 4..5) }
  scope :negative, -> { where(rating: 1..2) }
  
  # Methods
  def rating_stars
    "★" * rating + "☆" * (5 - rating)
  end
  
  def positive?
    rating >= 4
  end
  
  def negative?
    rating <= 2
  end
  
  # Callbacks
  after_create :update_business_rating
  after_update :update_business_rating
  after_destroy :update_business_rating
  
  private
  
  def update_business_rating
    # This could trigger a job to recalculate business rating
    business.touch
  end
end