class AddTranslationSupportToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :original_language, :string, default: 'fr'
    add_column :products, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :products, :translations, using: :gin
    add_index :products, :original_language
  end
end