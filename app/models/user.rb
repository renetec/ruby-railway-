class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Attributes
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  
  # Role management
  enum role: { member: 0, moderator: 1, admin: 2 }
  
  # Associations
  has_many :posts, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :forum_threads, dependent: :destroy
  has_many :forum_replies, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :businesses, dependent: :destroy
  has_many :event_rsvps, dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :volunteer_opportunities, dependent: :destroy
  has_many :volunteer_applications, dependent: :destroy
  has_many :business_reviews, dependent: :destroy
  has_one_attached :avatar

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }

  # Methods
  def full_name
    name
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator' || admin?
  end
end