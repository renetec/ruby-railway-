# Create admin user
admin = User.create!(
  name: "Admin User",
  email: "admin@leclub.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

# Create forum category
ForumCategory.create!(
  name: 'General Discussion',
  description: 'General community discussions',
  slug: 'general',
  position: 1,
  visible: true
)

# Create sample post
Post.create!(
  title: 'Welcome to LeClub Community Hub!',
  content: 'This is our new community platform where members can connect, share, and collaborate.',
  category: 'announcements',
  status: 'published',
  user: admin,
  featured: true
)

puts "Created basic seed data successfully!"