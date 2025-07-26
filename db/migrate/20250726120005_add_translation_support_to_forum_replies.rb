class AddTranslationSupportToForumReplies < ActiveRecord::Migration[7.2]
  def change
    add_column :forum_replies, :original_language, :string, default: 'fr'
    add_column :forum_replies, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :forum_replies, :translations, using: :gin
    add_index :forum_replies, :original_language
  end
end