class CreateForumReplies < ActiveRecord::Migration[7.2]
  def change
    create_table :forum_replies do |t|
      t.text :content, null: false
      t.integer :status, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :forum_thread, null: false, foreign_key: true
      t.references :parent_reply, null: true, foreign_key: { to_table: :forum_replies }

      t.timestamps
    end

    add_index :forum_replies, :status
    add_index :forum_replies, [:forum_thread_id, :created_at]
    add_index :forum_replies, [:user_id, :created_at]
    add_index :forum_replies, :created_at
  end
end