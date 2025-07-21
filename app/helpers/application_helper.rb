module ApplicationHelper
  def default_url_options
    { locale: I18n.locale }
  end
  
  def switch_locale_url(locale)
    url_for(locale: locale)
  end
  
  def current_locale_flag
    case I18n.locale.to_s
    when 'fr'
      '🇫🇷'
    when 'en'
      '🇬🇧'
    else
      '🌐'
    end
  end
  
  def localized_date(date, format = :default)
    l(date, format: format) if date
  end
  
  def localized_time_ago(time)
    return '' unless time
    
    time_diff = Time.current - time
    
    case I18n.locale
    when :fr
      if time_diff < 1.minute
        "À l'instant"
      elsif time_diff < 1.hour
        "il y a #{pluralize((time_diff / 1.minute).to_i, 'minute')}"
      elsif time_diff < 1.day
        "il y a #{pluralize((time_diff / 1.hour).to_i, 'heure')}"
      elsif time_diff < 1.week
        "il y a #{pluralize((time_diff / 1.day).to_i, 'jour')}"
      else
        l(time.to_date, format: :default)
      end
    else
      time_ago_in_words(time) + " ago"
    end
  end
end