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

ActiveRecord::Schema[8.1].define(version: 2026_10_08_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "status", default: 0, null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["role"], name: "index_admins_on_role"
    t.index ["status"], name: "index_admins_on_status"
  end

  create_table "daily_prices", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "admin_id", null: false
    t.date "priced_on", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_daily_prices_on_admin_id"
    t.index ["priced_on"], name: "index_daily_prices_on_priced_on"
    t.index ["product_id", "priced_on"], name: "index_daily_prices_on_product_id_and_priced_on", unique: true
    t.index ["product_id"], name: "index_daily_prices_on_product_id"
  end

  create_table "enquiries", force: :cascade do |t|
    t.string "name"
    t.string "company"
    t.string "email"
    t.string "phone"
    t.string "product_key"
    t.string "quantity"
    t.string "delivery_location"
    t.text "message"
    t.string "status", default: "new", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_enquiries_on_created_at"
    t.index ["status"], name: "index_enquiries_on_status"
  end

  create_table "guage_prices", force: :cascade do |t|
    t.bigint "guage_session_id", null: false
    t.bigint "product_id", null: false
    t.string "size", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.bigint "entered_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entered_by_id"], name: "index_guage_prices_on_entered_by_id"
    t.index ["guage_session_id", "product_id", "size"], name: "index_guage_prices_uniqueness", unique: true
    t.index ["guage_session_id"], name: "index_guage_prices_on_guage_session_id"
    t.index ["product_id"], name: "index_guage_prices_on_product_id"
    t.index ["updated_by_id"], name: "index_guage_prices_on_updated_by_id"
  end

  create_table "guage_sessions", force: :cascade do |t|
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_guage_sessions_on_created_by_id"
    t.check_constraint "ends_on >= starts_on", name: "guage_sessions_ends_after_start"
    t.exclusion_constraint "daterange(starts_on, ends_on, '[]'::text) WITH &&", using: :gist, name: "guage_sessions_no_overlap"
  end

  create_table "products", force: :cascade do |t|
    t.string "slug", null: false
    t.string "key", null: false
    t.string "category", null: false
    t.string "title", null: false
    t.string "eyebrow"
    t.text "summary"
    t.text "description"
    t.string "visual"
    t.string "accent"
    t.string "image_url"
    t.string "tags", default: [], null: false, array: true
    t.string "sizes", default: [], null: false, array: true
    t.string "applications", default: [], null: false, array: true
    t.jsonb "specs", default: [], null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_guage_price", default: false, null: false
    t.index ["key"], name: "index_products_on_key"
    t.index ["position"], name: "index_products_on_position"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "gstn"
    t.decimal "gst_percent", precision: 5, scale: 2
    t.decimal "loading_charges", precision: 12, scale: 2
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "(true)", name: "index_settings_singleton", unique: true
    t.index ["updated_by_id"], name: "index_settings_on_updated_by_id"
  end

  add_foreign_key "daily_prices", "admins"
  add_foreign_key "daily_prices", "products"
  add_foreign_key "guage_prices", "admins", column: "entered_by_id"
  add_foreign_key "guage_prices", "admins", column: "updated_by_id"
  add_foreign_key "guage_prices", "guage_sessions"
  add_foreign_key "guage_prices", "products"
  add_foreign_key "guage_sessions", "admins", column: "created_by_id"
  add_foreign_key "settings", "admins", column: "updated_by_id"
end
