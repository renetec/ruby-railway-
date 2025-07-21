class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :category, null: false
      t.integer :status, default: 0
      t.boolean :featured, default: false
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.integer :views_count, default: 0
      t.text :excerpt

      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, :status
    add_index :posts, :category
    add_index :posts, :featured
    add_index :posts, [:user_id, :created_at]
    add_index :posts, :created_at
  end
end