class EventTranslationJob < ApplicationJob
  queue_as :default
  
  def perform(event)
    return unless event.persisted?
    
    Rails.logger.info "Starting translation for event #{event.id}: #{event.title}"
    
    begin
      LibreTranslateService.translate_event_content(event)
      Rails.logger.info "Translation completed for event #{event.id}"
    rescue => e
      Rails.logger.error "Translation failed for event #{event.id}: #{e.message}"
      # Don't raise the error to avoid retries - translation is not critical
    end
  end
end