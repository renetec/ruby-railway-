class CreateForumCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :forum_categories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false
      t.boolean :visible, default: true
      t.string :slug
      t.integer :forum_threads_count, default: 0

      t.timestamps
    end

    add_index :forum_categories, :slug, unique: true
    add_index :forum_categories, :name, unique: true
    add_index :forum_categories, :position
    add_index :forum_categories, :visible
  end
end