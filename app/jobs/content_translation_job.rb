class ContentTranslationJob < ApplicationJob
  queue_as :default

  def perform(record)
    return unless record.respond_to?(:original_language) && record.respond_to?(:translations)
    
    # Skip if translations already exist for all target languages
    target_languages = %w[en es fr] - [record.original_language || 'fr']
    return if target_languages.all? { |lang| record.translations.dig(lang)&.present? }

    case record.class.name
    when 'Event'
      LibreTranslateService.translate_event_content(record)
    when 'Post'
      LibreTranslateService.translate_post_content(record)
    when 'Business'
      LibreTranslateService.translate_business_content(record)
    when 'Job'
      LibreTranslateService.translate_job_content(record)
    when 'ForumThread'
      LibreTranslateService.translate_forum_thread_content(record)
    when 'ForumReply'
      LibreTranslateService.translate_forum_reply_content(record)
    when 'VolunteerOpportunity'
      LibreTranslateService.translate_volunteer_opportunity_content(record)
    when 'Product'
      LibreTranslateService.translate_product_content(record)
    else
      Rails.logger.warn "ContentTranslationJob: Unknown model type #{record.class.name}"
    end
  rescue => e
    Rails.logger.error "ContentTranslationJob failed for #{record.class.name} ##{record.id}: #{e.message}"
    # Don't re-raise to avoid infinite retry loops
  end
end