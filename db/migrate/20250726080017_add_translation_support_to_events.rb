class AddTranslationSupportToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :original_language, :string, default: 'fr'
    add_column :events, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :events, :translations, using: :gin
    add_index :events, :original_language
  end
end