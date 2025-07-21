class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :job_type, null: false
      t.integer :experience_level, null: false
      t.string :location
      t.boolean :remote, default: false
      t.decimal :salary_min, precision: 10, scale: 2
      t.decimal :salary_max, precision: 10, scale: 2
      t.datetime :application_deadline
      t.text :requirements
      t.text :benefits
      t.integer :status, default: 0
      t.boolean :urgent, default: false
      t.boolean :featured, default: false
      t.string :slug
      t.references :business, null: false, foreign_key: true
      t.integer :applications_count, default: 0

      t.timestamps
    end

    add_index :jobs, :slug, unique: true
    add_index :jobs, :job_type
    add_index :jobs, :experience_level
    add_index :jobs, :status
    add_index :jobs, :remote
    add_index :jobs, :urgent
    add_index :jobs, :featured
    add_index :jobs, [:business_id, :created_at]
    add_index :jobs, :application_deadline
    add_index :jobs, :created_at
  end
end