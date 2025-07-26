class AddTranslationSupportToForumThreads < ActiveRecord::Migration[7.2]
  def change
    add_column :forum_threads, :original_language, :string, default: 'fr'
    add_column :forum_threads, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :forum_threads, :translations, using: :gin
    add_index :forum_threads, :original_language
  end
end