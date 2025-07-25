module EventsHelper
  def get_event_emoji(category)
    case category
    when 'workshop'
      '🛠️'
    when 'meetup'
      '🤝'
    when 'conference'
      '🎤'
    when 'social'
      '🎉'
    when 'training'
      '📚'
    when 'networking'
      '🌐'
    when 'webinar'
      '💻'
    when 'hackathon'
      '💡'
    else
      '📅'
    end
  end
  
  def event_category_options
    [
      ['Workshop', 'workshop'],
      ['Meetup', 'meetup'],
      ['Conference', 'conference'],
      ['Social', 'social'],
      ['Training', 'training'],
      ['Networking', 'networking'],
      ['Webinar', 'webinar'],
      ['Hackathon', 'hackathon']
    ]
  end
  
  def event_status_badge(status)
    case status
    when 'upcoming'
      content_tag :span, 'Upcoming', class: 'px-2 py-1 text-xs font-medium rounded bg-green-100 text-green-800'
    when 'ongoing'
      content_tag :span, 'Ongoing', class: 'px-2 py-1 text-xs font-medium rounded bg-blue-100 text-blue-800'
    when 'completed'
      content_tag :span, 'Completed', class: 'px-2 py-1 text-xs font-medium rounded bg-gray-100 text-gray-800'
    when 'cancelled'
      content_tag :span, 'Cancelled', class: 'px-2 py-1 text-xs font-medium rounded bg-red-100 text-red-800'
    else
      content_tag :span, status.humanize, class: 'px-2 py-1 text-xs font-medium rounded bg-gray-100 text-gray-800'
    end
  end
end