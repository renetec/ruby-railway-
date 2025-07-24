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
  
  # Messaging associations
  has_many :user_conversations, dependent: :destroy
  has_many :conversations, through: :user_conversations
  has_many :messages, dependent: :destroy

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }
  scope :online, -> { where('last_seen_at > ?', 5.minutes.ago) }

  # Methods
  def full_name
    name
  end

  def display_name
    nickname.present? ? nickname : name
  end

  def admin?
    role == 'admin'
  end

  def moderator?
    role == 'moderator' || admin?
  end
  
  def online?
    last_seen_at && last_seen_at > 5.minutes.ago
  end
  
  def appear
    update_column(:last_seen_at, Time.current)
  end
  
  def disappear
    update_column(:last_seen_at, 1.hour.ago)
  end
  
  def away
    update_column(:last_seen_at, 10.minutes.ago)
  end
end