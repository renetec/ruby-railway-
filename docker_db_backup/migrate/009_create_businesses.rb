class CreateBusinesses < ActiveRecord::Migration[7.2]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone
      t.string :email
      t.string :website
      t.text :hours
      t.integer :status, default: 0
      t.boolean :featured, default: false
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.decimal :rating, precision: 3, scale: 2, default: 0
      t.integer :reviews_count, default: 0

      t.timestamps
    end

    add_index :businesses, :slug, unique: true
    add_index :businesses, :name
    add_index :businesses, :category
    add_index :businesses, :status
    add_index :businesses, :featured
    add_index :businesses, [:user_id, :created_at]
    add_index :businesses, :city
    add_index :businesses, :rating
  end
end