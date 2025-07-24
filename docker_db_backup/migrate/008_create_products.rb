class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.integer :condition, default: 0
      t.integer :status, default: 0
      t.string :location
      t.boolean :featured, default: false
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.datetime :sold_at
      t.integer :views_count, default: 0

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :status
    add_index :products, :category
    add_index :products, :condition
    add_index :products, :featured
    add_index :products, [:user_id, :created_at]
    add_index :products, :price
    add_index :products, :created_at
  end
end