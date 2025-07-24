class Admin::DashboardController < AdminController
  def index
    @users_count = User.count
    @posts_count = Post.count
    @events_count = Event.count
    @forum_threads_count = ForumThread.count
    @products_count = Product.count
    @businesses_count = Business.count
    @jobs_count = Job.count
    @volunteer_opportunities_count = VolunteerOpportunity.count
    
    # Recent activity
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_posts = Post.order(created_at: :desc).limit(5)
    @recent_events = Event.order(created_at: :desc).limit(5)
  end
end