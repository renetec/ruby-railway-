class CreateJobApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.text :message
      t.integer :status, default: 0
      t.datetime :withdrawn_at

      t.timestamps
    end

    add_index :job_applications, [:user_id, :job_id], unique: true
    add_index :job_applications, :status
    add_index :job_applications, :created_at
    add_index :job_applications, [:job_id, :created_at]
  end
end