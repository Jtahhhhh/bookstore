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

ActiveRecord::Schema[8.1].define(version: 2026_05_06_033605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "authors", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "book_categories", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_categories_on_book_id"
    t.index ["category_id"], name: "index_book_categories_on_category_id"
  end

  create_table "books", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.boolean "published", default: true
    t.integer "stock", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "flash_sale_items", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "flash_sale_id", null: false
    t.decimal "sale_price", precision: 8, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_flash_sale_items_on_book_id"
    t.index ["flash_sale_id", "book_id"], name: "index_flash_sale_items_on_flash_sale_id_and_book_id", unique: true
    t.index ["flash_sale_id"], name: "index_flash_sale_items_on_flash_sale_id"
  end

  create_table "flash_sales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time", null: false
    t.string "name", null: false
    t.datetime "start_time", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.integer "quantity", default: 1
    t.decimal "subtotal", precision: 10, scale: 2
    t.decimal "unit_price", precision: 8, scale: 2
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_order_items_on_book_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email"
    t.string "customer_name"
    t.string "status", default: "pending"
    t.decimal "total_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "payment_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at"
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_payment_events_on_event_id", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "failed_reason"
    t.bigint "order_id", null: false
    t.datetime "paid_at"
    t.string "provider", null: false
    t.string "provider_transaction_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["provider_transaction_id"], name: "index_payments_on_provider_transaction_id", unique: true
  end

  create_table "reservation_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "flash_sale_item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "reservation_id", null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["flash_sale_item_id"], name: "index_reservation_items_on_flash_sale_item_id"
    t.index ["reservation_id", "flash_sale_item_id"], name: "idx_on_reservation_id_flash_sale_item_id_a1bd1727a8", unique: true
    t.index ["reservation_id"], name: "index_reservation_items_on_reservation_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "flash_sale_id", null: false
    t.string "idempotency_key", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["flash_sale_id"], name: "index_reservations_on_flash_sale_id"
    t.index ["idempotency_key"], name: "index_reservations_on_idempotency_key", unique: true
  end

  add_foreign_key "book_categories", "books"
  add_foreign_key "book_categories", "categories"
  add_foreign_key "books", "authors"
  add_foreign_key "flash_sale_items", "books"
  add_foreign_key "flash_sale_items", "flash_sales"
  add_foreign_key "order_items", "books"
  add_foreign_key "order_items", "orders"
  add_foreign_key "payments", "orders"
  add_foreign_key "reservation_items", "flash_sale_items"
  add_foreign_key "reservation_items", "reservations"
  add_foreign_key "reservations", "flash_sales"
end
