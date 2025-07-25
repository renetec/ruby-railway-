module ApplicationHelper
  def unread_messages_count
    return 0 unless user_signed_in?
    0
  end
  
  def user_avatar(user, size: 40, css_class: "")
    if user.avatar.attached?
      image_tag user.avatar, class: "w-#{size/4} h-#{size/4} rounded-full object-cover #{css_class}"
    elsif user.avatar_preset.present?
      image_tag "avatars/#{user.avatar_preset}.png", class: "w-#{size/4} h-#{size/4} rounded-full #{css_class}"
    else
      content_tag :div, class: "w-#{size/4} h-#{size/4} rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white font-bold text-#{size/8} #{css_class}" do
        user.email.first.upcase
      end
    end
  end
end
