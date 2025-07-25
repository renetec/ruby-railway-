class CreateForumThreads < ActiveRecord::Migration[7.2]
  def change
    create_table :forum_threads do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.integer :status, default: 0
      t.boolean :locked, default: false
      t.boolean :pinned, default: false
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.references :forum_category, null: false, foreign_key: true
      t.integer :forum_replies_count, default: 0
      t.integer :views_count, default: 0

      t.timestamps
    end

    add_index :forum_threads, :slug, unique: true
    add_index :forum_threads, :status
    add_index :forum_threads, :locked
    add_index :forum_threads, :pinned
    add_index :forum_threads, [:forum_category_id, :updated_at]
    add_index :forum_threads, [:user_id, :created_at]
    add_index :forum_threads, :updated_at
  end
end