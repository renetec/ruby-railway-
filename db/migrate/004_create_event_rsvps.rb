class CreateEventRsvps < ActiveRecord::Migration[7.2]
  def change
    create_table :event_rsvps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.integer :status, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :event_rsvps, [:user_id, :event_id], unique: true
    add_index :event_rsvps, :status
    add_index :event_rsvps, :created_at
  end
end