# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 15) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_reviews", force: :cascade do |t|
    t.integer "rating", null: false
    t.text "content", null: false
    t.bigint "user_id", null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "created_at"], name: "index_business_reviews_on_business_id_and_created_at"
    t.index ["business_id"], name: "index_business_reviews_on_business_id"
    t.index ["created_at"], name: "index_business_reviews_on_created_at"
    t.index ["rating"], name: "index_business_reviews_on_rating"
    t.index ["user_id", "business_id"], name: "index_business_reviews_on_user_id_and_business_id", unique: true
    t.index ["user_id"], name: "index_business_reviews_on_user_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "category", null: false
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.text "hours"
    t.integer "status", default: 0
    t.boolean "featured", default: false
    t.string "slug"
    t.bigint "user_id", null: false
    t.decimal "rating", precision: 3, scale: 2, default: "0.0"
    t.integer "reviews_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_businesses_on_category"
    t.index ["city"], name: "index_businesses_on_city"
    t.index ["featured"], name: "index_businesses_on_featured"
    t.index ["name"], name: "index_businesses_on_name"
    t.index ["rating"], name: "index_businesses_on_rating"
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["status"], name: "index_businesses_on_status"
    t.index ["user_id", "created_at"], name: "index_businesses_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "event_rsvps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.integer "status", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_event_rsvps_on_created_at"
    t.index ["event_id"], name: "index_event_rsvps_on_event_id"
    t.index ["status"], name: "index_event_rsvps_on_status"
    t.index ["user_id", "event_id"], name: "index_event_rsvps_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_event_rsvps_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "date", null: false
    t.string "location", null: false
    t.integer "capacity", null: false
    t.integer "rsvp_count", default: 0
    t.integer "category", default: 0
    t.integer "status", default: 0
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.string "slug"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_events_on_category"
    t.index ["date", "status"], name: "index_events_on_date_and_status"
    t.index ["date"], name: "index_events_on_date"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["status"], name: "index_events_on_status"
    t.index ["user_id", "created_at"], name: "index_events_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "forum_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position", null: false
    t.boolean "visible", default: true
    t.string "slug"
    t.integer "forum_threads_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_forum_categories_on_name", unique: true
    t.index ["position"], name: "index_forum_categories_on_position"
    t.index ["slug"], name: "index_forum_categories_on_slug", unique: true
    t.index ["visible"], name: "index_forum_categories_on_visible"
  end

  create_table "forum_replies", force: :cascade do |t|
    t.text "content", null: false
    t.integer "status", default: 0
    t.bigint "user_id", null: false
    t.bigint "forum_thread_id", null: false
    t.bigint "parent_reply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_forum_replies_on_created_at"
    t.index ["forum_thread_id", "created_at"], name: "index_forum_replies_on_forum_thread_id_and_created_at"
    t.index ["forum_thread_id"], name: "index_forum_replies_on_forum_thread_id"
    t.index ["parent_reply_id"], name: "index_forum_replies_on_parent_reply_id"
    t.index ["status"], name: "index_forum_replies_on_status"
    t.index ["user_id", "created_at"], name: "index_forum_replies_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_forum_replies_on_user_id"
  end

  create_table "forum_threads", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "status", default: 0
    t.boolean "locked", default: false
    t.boolean "pinned", default: false
    t.string "slug"
    t.bigint "user_id", null: false
    t.bigint "forum_category_id", null: false
    t.integer "forum_replies_count", default: 0
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_category_id", "updated_at"], name: "index_forum_threads_on_forum_category_id_and_updated_at"
    t.index ["forum_category_id"], name: "index_forum_threads_on_forum_category_id"
    t.index ["locked"], name: "index_forum_threads_on_locked"
    t.index ["pinned"], name: "index_forum_threads_on_pinned"
    t.index ["slug"], name: "index_forum_threads_on_slug", unique: true
    t.index ["status"], name: "index_forum_threads_on_status"
    t.index ["updated_at"], name: "index_forum_threads_on_updated_at"
    t.index ["user_id", "created_at"], name: "index_forum_threads_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_forum_threads_on_user_id"
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.text "message"
    t.integer "status", default: 0
    t.datetime "withdrawn_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_job_applications_on_created_at"
    t.index ["job_id", "created_at"], name: "index_job_applications_on_job_id_and_created_at"
    t.index ["job_id"], name: "index_job_applications_on_job_id"
    t.index ["status"], name: "index_job_applications_on_status"
    t.index ["user_id", "job_id"], name: "index_job_applications_on_user_id_and_job_id", unique: true
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "job_type", null: false
    t.integer "experience_level", null: false
    t.string "location"
    t.boolean "remote", default: false
    t.decimal "salary_min", precision: 10, scale: 2
    t.decimal "salary_max", precision: 10, scale: 2
    t.datetime "application_deadline"
    t.text "requirements"
    t.text "benefits"
    t.integer "status", default: 0
    t.boolean "urgent", default: false
    t.boolean "featured", default: false
    t.string "slug"
    t.bigint "business_id", null: false
    t.integer "applications_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_deadline"], name: "index_jobs_on_application_deadline"
    t.index ["business_id", "created_at"], name: "index_jobs_on_business_id_and_created_at"
    t.index ["business_id"], name: "index_jobs_on_business_id"
    t.index ["created_at"], name: "index_jobs_on_created_at"
    t.index ["experience_level"], name: "index_jobs_on_experience_level"
    t.index ["featured"], name: "index_jobs_on_featured"
    t.index ["job_type"], name: "index_jobs_on_job_type"
    t.index ["remote"], name: "index_jobs_on_remote"
    t.index ["slug"], name: "index_jobs_on_slug", unique: true
    t.index ["status"], name: "index_jobs_on_status"
    t.index ["urgent"], name: "index_jobs_on_urgent"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.string "category", null: false
    t.integer "status", default: 0
    t.boolean "featured", default: false
    t.string "slug"
    t.bigint "user_id", null: false
    t.integer "views_count", default: 0
    t.text "excerpt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_posts_on_category"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["featured"], name: "index_posts_on_featured"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["status"], name: "index_posts_on_status"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "category", null: false
    t.integer "condition", default: 0
    t.integer "status", default: 0
    t.string "location"
    t.boolean "featured", default: false
    t.string "slug"
    t.bigint "user_id", null: false
    t.datetime "sold_at"
    t.integer "views_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_products_on_category"
    t.index ["condition"], name: "index_products_on_condition"
    t.index ["created_at"], name: "index_products_on_created_at"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["price"], name: "index_products_on_price"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.index ["user_id", "created_at"], name: "index_products_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.integer "role", default: 0
    t.boolean "active", default: true
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "volunteer_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "volunteer_opportunity_id", null: false
    t.text "message"
    t.text "availability", null: false
    t.integer "status", default: 0
    t.datetime "withdrawn_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_volunteer_applications_on_created_at"
    t.index ["status"], name: "index_volunteer_applications_on_status"
    t.index ["user_id", "volunteer_opportunity_id"], name: "index_volunteer_applications_on_user_and_opportunity", unique: true
    t.index ["user_id"], name: "index_volunteer_applications_on_user_id"
    t.index ["volunteer_opportunity_id", "created_at"], name: "index_volunteer_applications_on_opportunity_and_created_at"
    t.index ["volunteer_opportunity_id"], name: "index_volunteer_applications_on_volunteer_opportunity_id"
  end

  create_table "volunteer_opportunities", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "category", null: false
    t.integer "time_commitment", null: false
    t.string "location"
    t.boolean "remote", default: false
    t.date "start_date"
    t.date "end_date"
    t.datetime "application_deadline"
    t.integer "volunteers_needed"
    t.integer "current_volunteers", default: 0
    t.text "requirements"
    t.integer "status", default: 0
    t.boolean "urgent", default: false
    t.boolean "featured", default: false
    t.string "slug"
    t.bigint "user_id", null: false
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_deadline"], name: "index_volunteer_opportunities_on_application_deadline"
    t.index ["category"], name: "index_volunteer_opportunities_on_category"
    t.index ["created_at"], name: "index_volunteer_opportunities_on_created_at"
    t.index ["featured"], name: "index_volunteer_opportunities_on_featured"
    t.index ["organization_id"], name: "index_volunteer_opportunities_on_organization_id"
    t.index ["remote"], name: "index_volunteer_opportunities_on_remote"
    t.index ["slug"], name: "index_volunteer_opportunities_on_slug", unique: true
    t.index ["start_date"], name: "index_volunteer_opportunities_on_start_date"
    t.index ["status"], name: "index_volunteer_opportunities_on_status"
    t.index ["time_commitment"], name: "index_volunteer_opportunities_on_time_commitment"
    t.index ["urgent"], name: "index_volunteer_opportunities_on_urgent"
    t.index ["user_id", "created_at"], name: "index_volunteer_opportunities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_volunteer_opportunities_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_reviews", "businesses"
  add_foreign_key "business_reviews", "users"
  add_foreign_key "businesses", "users"
  add_foreign_key "event_rsvps", "events"
  add_foreign_key "event_rsvps", "users"
  add_foreign_key "events", "users"
  add_foreign_key "forum_replies", "forum_replies", column: "parent_reply_id"
  add_foreign_key "forum_replies", "forum_threads"
  add_foreign_key "forum_replies", "users"
  add_foreign_key "forum_threads", "forum_categories"
  add_foreign_key "forum_threads", "users"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "users"
  add_foreign_key "jobs", "businesses"
  add_foreign_key "posts", "users"
  add_foreign_key "products", "users"
  add_foreign_key "volunteer_applications", "users"
  add_foreign_key "volunteer_applications", "volunteer_opportunities"
  add_foreign_key "volunteer_opportunities", "businesses", column: "organization_id"
  add_foreign_key "volunteer_opportunities", "users"
end
