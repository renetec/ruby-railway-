class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.string :name
      t.integer :conversation_type, default: 0, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.json :settings, default: {}

      t.timestamps
    end
    
    add_index :conversations, :conversation_type
    add_index :conversations, :updated_at
  end
end
