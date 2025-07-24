class JobApplication < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :job
  has_one_attached :resume
  has_one_attached :cover_letter
  
  # Validations
  validates :user_id, uniqueness: { scope: :job_id, message: "has already applied to this job" }
  validates :status, inclusion: { in: %w[pending reviewed interviewing hired rejected withdrawn] }
  validates :message, length: { maximum: 1000 }
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :reviewed, -> { where(status: 'reviewed') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Enums
  enum status: { 
    pending: 0, 
    reviewed: 1, 
    interviewing: 2, 
    hired: 3, 
    rejected: 4, 
    withdrawn: 5 
  }
  
  # Methods
  def business
    job.business
  end
  
  def can_withdraw?
    pending? || reviewed? || interviewing?
  end
  
  def status_badge_class
    case status
    when 'pending' then 'bg-yellow-100 text-yellow-800'
    when 'reviewed' then 'bg-blue-100 text-blue-800'
    when 'interviewing' then 'bg-purple-100 text-purple-800'
    when 'hired' then 'bg-green-100 text-green-800'
    when 'rejected' then 'bg-red-100 text-red-800'
    when 'withdrawn' then 'bg-gray-100 text-gray-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
  
  def withdraw!
    return false unless can_withdraw?
    
    update(status: 'withdrawn', withdrawn_at: Time.current)
  end
  
  # Callbacks
  after_create :notify_business_owner
  after_update :notify_applicant_status_change, if: :saved_change_to_status?
  
  private
  
  def notify_business_owner
    # Future: Send notification to business owner about new application
  end
  
  def notify_applicant_status_change
    # Future: Send notification to applicant about status change
  end
end