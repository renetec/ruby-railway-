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
  
  def self.available_languages
    SUPPORTED_LANGUAGES
  end
end