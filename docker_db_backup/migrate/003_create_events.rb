class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :date, null: false
      t.string :location, null: false
      t.integer :capacity, null: false
      t.integer :rsvp_count, default: 0
      t.integer :category, default: 0
      t.integer :status, default: 0
      t.decimal :price, precision: 8, scale: 2, default: 0
      t.string :slug
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :slug, unique: true
    add_index :events, :date
    add_index :events, :status
    add_index :events, :category
    add_index :events, [:date, :status]
    add_index :events, [:user_id, :created_at]
  end
end