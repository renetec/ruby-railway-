class LibreTranslateService
  include HTTParty
  
  # Using MyMemory API - genuinely free with no API key required
  base_uri 'https://api.mymemory.translated.net'
  
  SUPPORTED_LANGUAGES = {
    'fr' => 'French',
    'en' => 'English', 
    'es' => 'Spanish'
  }.freeze
  
  LANGUAGE_DETECTION_PATTERNS = {
    'fr' => /\b(le|la|les|de|du|des|et|est|dans|pour|avec|sur|par|ce|cette|qui|que|où|comment|pourquoi)\b/i,
    'en' => /\b(the|and|is|in|for|with|on|by|this|that|who|what|where|how|why)\b/i,
    'es' => /\b(el|la|los|las|de|del|y|es|en|para|con|por|este|esta|que|quien|donde|como|por qué)\b/i
  }.freeze
  
  def self.translate(text, from_language, to_language)
    return text if from_language == to_language
    return text if text.blank?
    
    begin
      # MyMemory API is completely free - no API key required!
      # Format: /get?q=text&langpair=source|target
      response = get('/get', {
        query: {
          q: text,
          langpair: "#{from_language}|#{to_language}"
        },
        timeout: 30
      })
      
      if response.success?
        result = response.parsed_response
        if result.is_a?(Hash) && result['responseData'] && result['responseData']['translatedText']
          translated = result['responseData']['translatedText']
          # MyMemory sometimes returns the original text in uppercase when it can't translate
          if translated == text.upcase
            return text
          end
          # Convert all-caps translations to proper case
          if translated == translated.upcase && translated.length > 3
            translated = translated.split(' ').map(&:capitalize).join(' ')
          end
          translated
        else
          Rails.logger.warn "MyMemory unexpected response format: #{result}"
          text
        end
      else
        Rails.logger.error "MyMemory API error: #{response.code} - #{response.body}"
        text # Return original text on error
      end
    rescue => e
      Rails.logger.error "MyMemory translation service error: #{e.message}"
      text # Return original text on error
    end
  end
  
  def self.detect_language(text)
    return 'fr' if text.blank? # Default to French
    
    # Clean text for analysis
    clean_text = text.downcase.gsub(/<[^>]*>/, ' ').gsub(/[^\w\s]/, ' ')
    
    # Count matches for each language
    scores = {}
    LANGUAGE_DETECTION_PATTERNS.each do |lang, pattern|
      matches = clean_text.scan(pattern).length
      scores[lang] = matches
    end
    
    # Return language with highest score, default to French
    detected = scores.max_by { |_, score| score }&.first
    detected && scores[detected] > 0 ? detected : 'fr'
  end
  
  def self.translate_event_content(event)
    original_lang = event.original_language || detect_language("#{event.title} #{event.description}")
    
    # Update original language if not set
    event.update_column(:original_language, original_lang) unless event.original_language
    
    translations = event.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'title').present? && translations.dig(target_lang, 'description').present?
      
      # Translate title and description
      translated_title = translate(event.title, original_lang, target_lang)
      translated_description = translate(event.description, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'title' => translated_title,
        'description' => translated_description,
        'location' => event.location.present? ? translate(event.location, original_lang, target_lang) : nil
      }
    end
    
    event.update_column(:translations, translations)
    translations
  end
  
  def self.translate_post_content(post)
    original_lang = post.original_language || detect_language("#{post.title} #{post.content}")
    
    # Update original language if not set
    post.update_column(:original_language, original_lang) unless post.original_language
    
    translations = post.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'title').present? && translations.dig(target_lang, 'content').present?
      
      # Translate title and content
      translated_title = translate(post.title, original_lang, target_lang)
      translated_content = translate(post.content, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'title' => translated_title,
        'content' => translated_content
      }
    end
    
    post.update_column(:translations, translations)
    translations
  end
  
  def self.translate_business_content(business)
    original_lang = business.original_language || detect_language("#{business.name} #{business.description}")
    
    # Update original language if not set
    business.update_column(:original_language, original_lang) unless business.original_language
    
    translations = business.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'name').present? && translations.dig(target_lang, 'description').present?
      
      # Translate name, description, and address
      translated_name = translate(business.name, original_lang, target_lang)
      translated_description = translate(business.description, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'name' => translated_name,
        'description' => translated_description,
        'address' => business.address.present? ? translate(business.address, original_lang, target_lang) : nil
      }
    end
    
    business.update_column(:translations, translations)
    translations
  end
  
  def self.translate_job_content(job)
    original_lang = job.original_language || detect_language("#{job.title} #{job.description}")
    
    # Update original language if not set
    job.update_column(:original_language, original_lang) unless job.original_language
    
    translations = job.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'title').present? && translations.dig(target_lang, 'description').present?
      
      # Translate title, description, and requirements
      translated_title = translate(job.title, original_lang, target_lang)
      translated_description = translate(job.description, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'title' => translated_title,
        'description' => translated_description,
        'requirements' => job.requirements.present? ? translate(job.requirements, original_lang, target_lang) : nil
      }
    end
    
    job.update_column(:translations, translations)
    translations
  end
  
  def self.translate_forum_thread_content(forum_thread)
    original_lang = forum_thread.original_language || detect_language("#{forum_thread.title} #{forum_thread.content}")
    
    # Update original language if not set
    forum_thread.update_column(:original_language, original_lang) unless forum_thread.original_language
    
    translations = forum_thread.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'title').present? && translations.dig(target_lang, 'content').present?
      
      # Translate title and content
      translated_title = translate(forum_thread.title, original_lang, target_lang)
      translated_content = translate(forum_thread.content, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'title' => translated_title,
        'content' => translated_content
      }
    end
    
    forum_thread.update_column(:translations, translations)
    translations
  end
  
  def self.translate_forum_reply_content(forum_reply)
    original_lang = forum_reply.original_language || detect_language(forum_reply.content)
    
    # Update original language if not set
    forum_reply.update_column(:original_language, original_lang) unless forum_reply.original_language
    
    translations = forum_reply.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'content').present?
      
      # Translate content
      translated_content = translate(forum_reply.content, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'content' => translated_content
      }
    end
    
    forum_reply.update_column(:translations, translations)
    translations
  end
  
  def self.translate_volunteer_opportunity_content(volunteer_opportunity)
    original_lang = volunteer_opportunity.original_language || detect_language("#{volunteer_opportunity.title} #{volunteer_opportunity.description}")
    
    # Update original language if not set
    volunteer_opportunity.update_column(:original_language, original_lang) unless volunteer_opportunity.original_language
    
    translations = volunteer_opportunity.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'title').present? && translations.dig(target_lang, 'description').present?
      
      # Translate title, description, and requirements
      translated_title = translate(volunteer_opportunity.title, original_lang, target_lang)
      translated_description = translate(volunteer_opportunity.description, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'title' => translated_title,
        'description' => translated_description,
        'requirements' => volunteer_opportunity.requirements.present? ? translate(volunteer_opportunity.requirements, original_lang, target_lang) : nil
      }
    end
    
    volunteer_opportunity.update_column(:translations, translations)
    translations
  end
  
  def self.translate_product_content(product)
    original_lang = product.original_language || detect_language("#{product.name} #{product.description}")
    
    # Update original language if not set
    product.update_column(:original_language, original_lang) unless product.original_language
    
    translations = product.translations || {}
    
    SUPPORTED_LANGUAGES.keys.each do |target_lang|
      next if target_lang == original_lang
      next if translations.dig(target_lang, 'name').present? && translations.dig(target_lang, 'description').present?
      
      # Translate name and description
      translated_name = translate(product.name, original_lang, target_lang)
      translated_description = translate(product.description, original_lang, target_lang)
      
      # Store translations
      translations[target_lang] = {
        'name' => translated_name,
        'description' => translated_description
      }
    end
    
    product.update_column(:translations, translations)
    translations
  end

  def self.available_languages
    SUPPORTED_LANGUAGES
  end
end