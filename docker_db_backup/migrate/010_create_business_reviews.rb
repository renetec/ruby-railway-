class CreateBusinessReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :business_reviews do |t|
      t.integer :rating, null: false
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end

    add_index :business_reviews, [:user_id, :business_id], unique: true
    add_index :business_reviews, :rating
    add_index :business_reviews, :created_at
    add_index :business_reviews, [:business_id, :created_at]
  end
end