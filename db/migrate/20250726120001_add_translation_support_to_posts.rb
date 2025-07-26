class AddTranslationSupportToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :original_language, :string, default: 'fr'
    add_column :posts, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :posts, :translations, using: :gin
    add_index :posts, :original_language
  end
end