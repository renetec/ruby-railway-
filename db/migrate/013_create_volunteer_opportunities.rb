class CreateVolunteerOpportunities < ActiveRecord::Migration[7.2]
  def change
    create_table :volunteer_opportunities do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.integer :time_commitment, null: false
      t.string :location
      t.boolean :remote, default: false
      t.date :start_date
      t.date :end_date
      t.datetime :application_deadline
      t.integer :volunteers_needed
      t.integer :current_volunteers, default: 0
      t.text :requirements
      t.integer :status, default: 0
      t.boolean :urgent, default: false
      t.boolean :featured, default: false
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: true, foreign_key: { to_table: :businesses }

      t.timestamps
    end

    add_index :volunteer_opportunities, :slug, unique: true
    add_index :volunteer_opportunities, :category
    add_index :volunteer_opportunities, :time_commitment
    add_index :volunteer_opportunities, :status
    add_index :volunteer_opportunities, :remote
    add_index :volunteer_opportunities, :urgent
    add_index :volunteer_opportunities, :featured
    add_index :volunteer_opportunities, [:user_id, :created_at]
    add_index :volunteer_opportunities, :start_date
    add_index :volunteer_opportunities, :application_deadline
    add_index :volunteer_opportunities, :created_at
  end
end