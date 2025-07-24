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
  
  def unread_messages_count
    return 0 unless user_signed_in?
    
    # Count unread messages across all conversations
    current_user.conversations
                .joins(:messages, :user_conversations)
                .where(user_conversations: { user: current_user })
                .where('messages.created_at > COALESCE(user_conversations.last_read_at, user_conversations.created_at)')
                .where.not(messages: { user: current_user })
                .count
  end
  
  def get_event_emoji(category)
    case category.to_s
    when 'community'
      '🏘️'
    when 'business'
      '💼'
    when 'education'
      '📚'
    when 'entertainment'
      '🎭'
    when 'sports'
      '⚽'
    when 'health'
      '🏥'
    when 'technology'
      '💻'
    when 'culture'
      '🎨'
    when 'volunteer'
      '🤝'
    else
      '📅'
    end
  end

  # Avatar Helper Methods
  def user_avatar(user, size: 40, css_class: "rounded-full object-cover")
    if user.avatar.attached?
      image_tag user.avatar, alt: user.display_name, class: "w-#{size/4} h-#{size/4} #{css_class}"
    elsif user.avatar_preset.present?
      render_preset_avatar(user.avatar_preset, size, css_class)
    else
      render_default_avatar(user, size, css_class)
    end
  end

  def avatar_presets_by_category
    {
      'animals' => [
        { emoji: '🐱', color: '#f59e0b', name: 'Chat' },
        { emoji: '🐶', color: '#8b5cf6', name: 'Chien' },
        { emoji: '🐻', color: '#ef4444', name: 'Ours' },
        { emoji: '🦊', color: '#f97316', name: 'Renard' },
        { emoji: '🐼', color: '#374151', name: 'Panda' },
        { emoji: '🦁', color: '#d97706', name: 'Lion' },
        { emoji: '🐯', color: '#dc2626', name: 'Tigre' },
        { emoji: '🐸', color: '#059669', name: 'Grenouille' }
      ],
      'faces' => [
        { emoji: '😊', color: '#0ea5e9', name: 'Souriant' },
        { emoji: '😎', color: '#6366f1', name: 'Cool' },
        { emoji: '🤓', color: '#8b5cf6', name: 'Geek' },
        { emoji: '😇', color: '#10b981', name: 'Ange' },
        { emoji: '🤗', color: '#f59e0b', name: 'Câlin' },
        { emoji: '😋', color: '#ef4444', name: 'Gourmand' },
        { emoji: '🥳', color: '#ec4899', name: 'Fête' },
        { emoji: '😴', color: '#64748b', name: 'Endormi' }
      ],
      'shapes' => [
        { emoji: '🔵', color: '#0ea5e9', name: 'Cercle Bleu' },
        { emoji: '🟣', color: '#8b5cf6', name: 'Cercle Violet' },
        { emoji: '🟢', color: '#10b981', name: 'Cercle Vert' },
        { emoji: '🟡', color: '#f59e0b', name: 'Cercle Jaune' },
        { emoji: '🔴', color: '#ef4444', name: 'Cercle Rouge' },
        { emoji: '🟠', color: '#f97316', name: 'Cercle Orange' },
        { emoji: '⭐', color: '#eab308', name: 'Étoile' },
        { emoji: '❤️', color: '#dc2626', name: 'Cœur' }
      ],
      'nature' => [
        { emoji: '🌳', color: '#059669', name: 'Arbre' },
        { emoji: '🌸', color: '#ec4899', name: 'Sakura' },
        { emoji: '🌻', color: '#eab308', name: 'Tournesol' },
        { emoji: '🌙', color: '#64748b', name: 'Lune' },
        { emoji: '☀️', color: '#f59e0b', name: 'Soleil' },
        { emoji: '🌊', color: '#0284c7', name: 'Vague' },
        { emoji: '🍀', color: '#16a34a', name: 'Trèfle' },
        { emoji: '🌈', color: '#8b5cf6', name: 'Arc-en-ciel' }
      ]
    }
  end

  def preset_key(preset)
    "#{preset[:emoji]}-#{preset[:color].gsub('#', '')}"
  end

  private

  def render_preset_avatar(preset_key, size, css_class)
    emoji, color = preset_key.split('-')
    color_hex = "##{color}" if color
    
    content_tag(:div, 
      class: "w-#{size/4} h-#{size/4} #{css_class} flex items-center justify-center text-white font-bold",
      style: "background: #{color_hex}; font-size: #{size/2}px;"
    ) do
      emoji
    end
  end

  def render_default_avatar(user, size, css_class)
    initial = user.display_name.first.upcase
    content_tag(:div,
      class: "w-#{size/4} h-#{size/4} #{css_class} flex items-center justify-center bg-blue-500 text-white font-bold",
      style: "font-size: #{size/3}px;"
    ) do
      initial
    end
  end
end