# Test translation system
puts "Testing translation system..."

# Find or create a test user
user = User.first || User.create!(
  email: 'test@example.com', 
  password: 'password123', 
  name: 'Test User'
)

puts "User: #{user.name}"

# Create a test event
event = user.events.create!(
  title: 'Événement de Test',
  description: 'Ceci est un événement de test en français pour vérifier la traduction automatique.',
  date: 1.week.from_now,
  location: 'Paris, France',
  category: 'community'
)

puts "Event created successfully!"
puts "Event ID: #{event.id}"
puts "Original language: #{event.original_language || 'not set'}"
puts "Title: #{event.title}"
puts "Description: #{event.description}"

# Check if translation columns exist
puts "Has translation columns: #{event.respond_to?(:translations)}"

if event.respond_to?(:translations)
  puts "Translations: #{event.translations}"
end