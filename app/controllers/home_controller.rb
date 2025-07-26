class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    @featured_posts = Post.published.featured.includes(:user).limit(3)
    @recent_posts = Post.published.recent.includes(:user).limit(6)
    @upcoming_events = Event.published.upcoming.includes(:user).limit(4)
    @forum_categories = ForumCategory.visible.ordered.includes(:forum_threads)
    @stats = {
      users_count: User.count,
      posts_count: Post.published.count,
      events_count: Event.published.count,
      forum_threads_count: ForumThread.published.count
    }
  end
end