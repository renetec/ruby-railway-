class AddTranslationSupportToVolunteerOpportunities < ActiveRecord::Migration[7.2]
  def change
    add_column :volunteer_opportunities, :original_language, :string, default: 'fr'
    add_column :volunteer_opportunities, :translations, :jsonb, default: {}
    
    # Add index for performance on translations JSONB column
    add_index :volunteer_opportunities, :translations, using: :gin
    add_index :volunteer_opportunities, :original_language
  end
end