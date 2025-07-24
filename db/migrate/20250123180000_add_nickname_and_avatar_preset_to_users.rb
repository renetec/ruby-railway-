class AddNicknameAndAvatarPresetToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :nickname, :string
    add_column :users, :avatar_preset, :string
    
    add_index :users, :nickname
  end
end