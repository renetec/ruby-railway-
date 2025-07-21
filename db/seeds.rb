# Create admin user
admin = User.create!(
  name: "Admin User",
  email: "admin@leclub.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

# Create moderator
moderator = User.create!(
  name: "Moderator User", 
  email: "moderator@leclub.com",
  password: "password123",
  password_confirmation: "password123",
  role: "moderator"
)

# Create sample users
users = []
5.times do |i|
  users << User.create!(
    name: "User #{i + 1}",
    email: "user#{i + 1}@leclub.com",
    password: "password123",
    password_confirmation: "password123",
    role: "member"
  )
end

puts "Created #{User.count} users"

# Create forum categories
forum_categories = [
  {
    name: "General Discussion",
    description: "General community discussions and introductions",
    position: 1
  },
  {
    name: "Events & Announcements", 
    description: "Community events and important announcements",
    position: 2
  },
  {
    name: "Business & Networking",
    description: "Business discussions, networking, and professional development",
    position: 3
  },
  {
    name: "Tech Talk",
    description: "Technology discussions, tips, and tutorials",
    position: 4
  },
  {
    name: "Marketplace",
    description: "Buy, sell, and trade items within the community",
    position: 5
  }
]

forum_categories.each do |category_data|
  ForumCategory.create!(category_data)
end

puts "Created #{ForumCategory.count} forum categories"

# Create sample posts
Post::CATEGORIES.each do |category|
  3.times do |i|
    Post.create!(
      title: "Sample #{category.humanize} Post #{i + 1}",
      content: "This is a sample post about #{category}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      category: category,
      status: "published",
      featured: i == 0, # Make first post in each category featured
      user: [admin, moderator, *users].sample
    )
  end
end

puts "Created #{Post.count} posts"

# Create sample events
Event.categories.keys.each do |category|
  2.times do |i|
    Event.create!(
      title: "Sample #{category.humanize} Event #{i + 1}",
      description: "This is a sample #{category} event. Join us for an exciting time!",
      date: rand(1..30).days.from_now,
      location: "Community Center #{i + 1}",
      capacity: rand(20..100),
      category: category,
      status: "published",
      user: [admin, moderator, *users].sample
    )
  end
end

puts "Created #{Event.count} events"

# Create sample forum threads
ForumCategory.all.each do |category|
  2.times do |i|
    thread = ForumThread.create!(
      title: "Sample Discussion #{i + 1} in #{category.name}",
      content: "This is a sample forum thread to get the discussion started. What are your thoughts?",
      status: "published",
      user: [admin, moderator, *users].sample,
      forum_category: category
    )
    
    # Add some replies
    rand(1..5).times do |j|
      ForumReply.create!(
        content: "This is a sample reply #{j + 1} to the discussion. Great points!",
        status: "published",
        user: [admin, moderator, *users].sample,
        forum_thread: thread
      )
    end
  end
end

puts "Created #{ForumThread.count} forum threads"
puts "Created #{ForumReply.count} forum replies"

# Create sample businesses
Business::CATEGORIES.each do |category|
  2.times do |i|
    business = Business.create!(
      name: "#{category.humanize} Business #{i + 1}",
      description: "A great #{category} business serving the community with excellent service and quality products.",
      category: category,
      address: "#{rand(100..999)} Main St",
      city: ["Springfield", "Riverside", "Madison", "Franklin"].sample,
      state: "CA",
      zip_code: "9#{rand(1000..9999)}",
      phone: "555#{rand(1000000..9999999)}",
      email: "contact@#{category}business#{i + 1}.com",
      website: "https://#{category}business#{i + 1}.com",
      status: "active",
      user: [admin, moderator, *users].sample
    )
    
    # Add some reviews
    available_users = [admin, moderator, *users].shuffle
    rand(1..3).times do |j|
      next if j >= available_users.length
      BusinessReview.create!(
        rating: rand(3..5),
        content: "Great service and quality products. Highly recommend!",
        user: available_users[j],
        business: business
      )
    end
  end
end

puts "Created #{Business.count} businesses"
puts "Created #{BusinessReview.count} business reviews"

# Create sample products
Product::CATEGORIES.each do |category|
  3.times do |i|
    Product.create!(
      name: "#{category.humanize} Item #{i + 1}",
      description: "A quality #{category} item in excellent condition. Perfect for anyone looking for a great deal!",
      price: rand(10..500),
      category: category,
      condition: Product.conditions.keys.sample,
      location: ["Springfield", "Riverside", "Madison"].sample,
      status: "active",
      featured: i == 0,
      user: [admin, moderator, *users].sample
    )
  end
end

puts "Created #{Product.count} products"

# Create sample jobs
Business.all.each do |business|
  rand(1..3).times do |i|
    job = Job.create!(
      title: "#{Job.job_types.keys.sample.humanize} #{Job.experience_levels.keys.sample.humanize} Position",
      description: "We are looking for a motivated individual to join our team. Great opportunity for growth and development.",
      job_type: Job.job_types.keys.sample,
      experience_level: Job.experience_levels.keys.sample,
      location: business.city,
      remote: [true, false].sample,
      salary_min: rand(30000..60000),
      salary_max: rand(60000..100000),
      application_deadline: rand(7..30).days.from_now,
      requirements: "Bachelor's degree preferred, excellent communication skills, team player",
      benefits: "Health insurance, 401k, paid time off, flexible schedule",
      status: "active",
      business: business
    )
    
    # Add some applications
    available_applicants = users.shuffle
    rand(0..2).times do |k|
      next if k >= available_applicants.length
      JobApplication.create!(
        user: available_applicants[k],
        job: job,
        message: "I am very interested in this position and believe I would be a great fit for your team.",
        status: JobApplication.statuses.keys.sample
      )
    end
  end
end

puts "Created #{Job.count} jobs"
puts "Created #{JobApplication.count} job applications"

# Create sample volunteer opportunities
VolunteerOpportunity::CATEGORIES.each do |category|
  2.times do |i|
    opportunity = VolunteerOpportunity.create!(
      title: "#{category.humanize} Volunteer Opportunity #{i + 1}",
      description: "Help make a difference in our community by volunteering for this important #{category} initiative.",
      category: category,
      time_commitment: VolunteerOpportunity.time_commitments.keys.sample,
      location: ["Community Center", "Library", "Park"].sample,
      remote: [true, false].sample,
      start_date: rand(1..14).days.from_now,
      end_date: rand(15..60).days.from_now,
      volunteers_needed: rand(5..20),
      requirements: "Must be 18+ years old, reliable, and passionate about helping others",
      status: "active",
      user: [admin, moderator].sample,
      organization: Business.all.sample
    )
    
    # Add some applications
    available_volunteers = users.shuffle
    rand(0..3).times do |l|
      next if l >= available_volunteers.length
      VolunteerApplication.create!(
        user: available_volunteers[l],
        volunteer_opportunity: opportunity,
        message: "I would love to help with this important cause.",
        availability: "Weekends and evenings work best for me",
        status: VolunteerApplication.statuses.keys.sample
      )
    end
  end
end

puts "Created #{VolunteerOpportunity.count} volunteer opportunities"
puts "Created #{VolunteerApplication.count} volunteer applications"

puts "Seed data created successfully!"