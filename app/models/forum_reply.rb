class ForumReply < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :forum_thread, counter_cache: true
  belongs_to :parent_reply, class_name: 'ForumReply', optional: true
  has_many :child_replies, class_name: 'ForumReply', foreign_key: 'parent_reply_id', dependent: :destroy
  
  # Validations
  validates :content, presence: true, length: { minimum: 3 }
  validates :status, inclusion: { in: %w[published edited deleted] }
  
  # Callbacks
  after_create :enqueue_translation_job
  after_update :enqueue_translation_job, if: :saved_change_to_content?
  
  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :top_level, -> { where(parent_reply: nil) }
  scope :replies_to, ->(parent) { where(parent_reply: parent) }
  
  # Enums
  enum status: { published: 0, edited: 1, deleted: 2 }
  
  # Methods
  def edited?
    updated_at > created_at + 5.minutes
  end
  
  def can_edit?(user)
    return false unless user
    
    self.user == user || user.moderator?
  end
  
  def can_delete?(user)
    return false unless user
    
    self.user == user || user.moderator?
  end
  
  def is_reply?
    parent_reply.present?
  end
  
  def depth
    return 0 unless parent_reply
    
    parent_reply.depth + 1
  end
  
  def nested_replies
    child_replies.includes(:user, :child_replies)
  end
  
  # Translation methods
  def translated_content(locale = I18n.locale)
    return content unless respond_to?(:original_language) && respond_to?(:translations)
    
    locale = locale.to_s
    return content if locale == original_language
    
    translations.dig(locale, 'content') || content
  end
  
  def translate_content!
    LibreTranslateService.translate_forum_reply_content(self)
  end
  
  # Callbacks
  after_create :update_thread_timestamp
  after_destroy :update_thread_timestamp
  
  private
  
  def update_thread_timestamp
    forum_thread.touch
  end
  
  def enqueue_translation_job
    return unless respond_to?(:original_language) && respond_to?(:translations)
    ContentTranslationJob.perform_later(self)
  end
end