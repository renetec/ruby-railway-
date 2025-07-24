class SearchController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    @query = params[:q]
    @category = params[:category]
    @page = params[:page] || 1
    
    return unless @query.present?
    
    # Search across all content types
    @results = search_all_content
    
    # Filter by category if specified
    @results = filter_by_category(@results) if @category.present?
    
    # Paginate results
    @results = paginate_results(@results)
    
    # Get result counts for each category
    @result_counts = {
      all: total_results_count,
      posts: search_posts.count,
      events: search_events.count,
      products: search_products.count,
      businesses: search_businesses.count,
      jobs: search_jobs.count,
      volunteers: search_volunteer_opportunities.count,
      forum: search_forum_threads.count
    }
  end
  
  private
  
  def search_all_content
    results = []
    
    case @category
    when 'posts'
      results = search_posts
    when 'events'
      results = search_events
    when 'products'
      results = search_products
    when 'businesses'
      results = search_businesses
    when 'jobs'
      results = search_jobs
    when 'volunteers'
      results = search_volunteer_opportunities
    when 'forum'
      results = search_forum_threads
    else
      # Search all content types
      results = [
        *search_posts.limit(10),
        *search_events.limit(10),
        *search_products.limit(10),
        *search_businesses.limit(10),
        *search_jobs.limit(10),
        *search_volunteer_opportunities.limit(10),
        *search_forum_threads.limit(10)
      ]
    end
    
    # Sort by relevance (created_at for now, could be enhanced)
    results.sort_by(&:created_at).reverse
  end
  
  def search_posts
    Post.published
        .search_by_term(@query)
        .includes(:user)
  end
  
  def search_events
    Event.published
         .upcoming
         .search_by_term(@query)
         .includes(:user)
  end
  
  def search_products
    Product.active
           .search_by_term(@query)
           .includes(:user, images_attachments: :blob)
  end
  
  def search_businesses
    Business.active
            .search_by_term(@query)
            .includes(:user, logo_attachment: :blob)
  end
  
  def search_jobs
    Job.active
       .search_by_term(@query)
       .includes(:business)
  end
  
  def search_volunteer_opportunities
    VolunteerOpportunity.active
                       .search_by_term(@query)
                       .includes(:user, :organization)
  end
  
  def search_forum_threads
    ForumThread.published
               .search_by_term(@query)
               .includes(:user, :forum_category)
  end
  
  def filter_by_category(results)
    case @category
    when 'posts'
      results.select { |r| r.is_a?(Post) }
    when 'events'
      results.select { |r| r.is_a?(Event) }
    when 'products'
      results.select { |r| r.is_a?(Product) }
    when 'businesses'
      results.select { |r| r.is_a?(Business) }
    when 'jobs'
      results.select { |r| r.is_a?(Job) }
    when 'volunteers'
      results.select { |r| r.is_a?(VolunteerOpportunity) }
    when 'forum'
      results.select { |r| r.is_a?(ForumThread) }
    else
      results
    end
  end
  
  def paginate_results(results)
    per_page = 20
    offset = ((@page.to_i - 1) * per_page)
    
    @total_pages = (results.count / per_page.to_f).ceil
    @current_page = @page.to_i
    
    results[offset, per_page] || []
  end
  
  def total_results_count
    return 0 unless @query.present?
    
    [
      search_posts.count,
      search_events.count,
      search_products.count,
      search_businesses.count,
      search_jobs.count,
      search_volunteer_opportunities.count,
      search_forum_threads.count
    ].sum
  end
end