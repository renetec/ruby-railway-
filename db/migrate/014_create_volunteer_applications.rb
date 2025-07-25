class CreateVolunteerApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :volunteer_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :volunteer_opportunity, null: false, foreign_key: true
      t.text :message
      t.text :availability, null: false
      t.integer :status, default: 0
      t.datetime :withdrawn_at

      t.timestamps
    end

    add_index :volunteer_applications, [:user_id, :volunteer_opportunity_id], unique: true, name: 'index_volunteer_applications_on_user_and_opportunity'
    add_index :volunteer_applications, :status
    add_index :volunteer_applications, :created_at
    add_index :volunteer_applications, [:volunteer_opportunity_id, :created_at], name: 'index_volunteer_applications_on_opportunity_and_created_at'
  end
end