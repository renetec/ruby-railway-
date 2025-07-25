class EventRsvp < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :event
  
  # Validations
  validates :user_id, uniqueness: { scope: :event_id, message: "has already RSVP'd to this event" }
  validate :event_has_capacity
  validate :event_is_upcoming
  
  # Callbacks
  after_create :increment_event_rsvp_count
  after_destroy :decrement_event_rsvp_count
  
  # Scopes
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  # Enums
  enum status: { confirmed: 0, cancelled: 1, waitlisted: 2 }
  
  private
  
  def event_has_capacity
    return unless event&.full?
    
    errors.add(:event, "is at full capacity")
  end
  
  def event_is_upcoming
    return unless event&.past_event?
    
    errors.add(:event, "has already occurred")
  end
  
  def increment_event_rsvp_count
    event.increment_rsvp_count!
  end
  
  def decrement_event_rsvp_count
    event.decrement_rsvp_count!
  end
end