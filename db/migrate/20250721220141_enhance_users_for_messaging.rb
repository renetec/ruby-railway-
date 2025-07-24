class EnhanceUsersForMessaging < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :last_seen_at, :timestamp
    add_column :users, :notification_preferences, :json, default: {}
    
    add_index :users, :last_seen_at
  end
end
