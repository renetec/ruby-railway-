class CreateUserConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :user_conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true
      t.timestamp :joined_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamp :left_at
      t.timestamp :last_read_at
      t.boolean :is_admin, default: false
      t.boolean :is_muted, default: false
      t.boolean :notification_enabled, default: true

      t.timestamps
    end
    
    add_index :user_conversations, [:user_id, :conversation_id], unique: true
    add_index :user_conversations, :last_read_at
  end
end
