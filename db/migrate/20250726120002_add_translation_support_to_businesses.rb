class AddTranslationSupportToBusinesses < ActiveRecord::Migration[7.2]
  def change
    add_column :businesses, :original_language, :string, default: 'fr'
    add_column :businesses, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :businesses, :translations, using: :gin
    add_index :businesses, :original_language
  end
end