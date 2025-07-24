class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :reply_to_message, foreign_key: { to_table: :messages }
      t.text :content
      t.integer :message_type, default: 0, null: false
      t.integer :delivery_status, default: 0, null: false
      t.timestamp :edited_at
      t.json :read_by, default: []

      t.timestamps
    end
    
    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :message_type
    add_index :messages, :created_at
  end
end
