class VolunteerApplication < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :volunteer_opportunity
  
  # Validations
  validates :user_id, uniqueness: { scope: :volunteer_opportunity_id, message: "has already applied to this opportunity" }
  validates :status, inclusion: { in: %w[pending accepted rejected withdrawn] }
  validates :message, length: { maximum: 1000 }
  validates :availability, presence: true, length: { maximum: 500 }
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Enums
  enum status: { 
    pending: 0, 
    accepted: 1, 
    rejected: 2, 
    withdrawn: 3 
  }
  
  # Methods
  def organization
    volunteer_opportunity.organization
  end
  
  def can_withdraw?
    pending? || accepted?
  end
  
  def status_badge_class
    case status
    when 'pending' then 'bg-yellow-100 text-yellow-800'
    when 'accepted' then 'bg-green-100 text-green-800'
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
  after_create :notify_opportunity_creator
  after_update :notify_applicant_status_change, if: :saved_change_to_status?
  after_update :update_opportunity_counters
  
  private
  
  def notify_opportunity_creator
    # Future: Send notification to opportunity creator about new application
  end
  
  def notify_applicant_status_change
    # Future: Send notification to applicant about status change
  end
  
  def update_opportunity_counters
    volunteer_opportunity.update(current_volunteers: volunteer_opportunity.volunteers_count)
  end
end