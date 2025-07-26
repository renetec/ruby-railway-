class AddTranslationSupportToJobs < ActiveRecord::Migration[7.2]
  def change
    add_column :jobs, :original_language, :string, default: 'fr'
    add_column :jobs, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :jobs, :translations, using: :gin
    add_index :jobs, :original_language
  end
end