# Test post translation
user = User.first

post = user.posts.create!(
  title: 'Article de Test en Français',
  content: 'Ceci est un article de test pour vérifier que le système de traduction fonctionne pour les articles aussi. Il devrait être traduit automatiquement en anglais et en espagnol.',
  category: 'news',
  status: 'published'
)

puts "Post created: #{post.title}"
puts "Post ID: #{post.id}"

# Wait a moment for background job
sleep 2

# Check translations 
puts "English title: #{post.translated_title('en')}"
puts "Spanish title: #{post.translated_title('es')}"