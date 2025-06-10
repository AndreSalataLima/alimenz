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

ActiveRecord::Schema[8.0].define(version: 2025_06_09_145300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "blocked_suppliers", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "supplier_id"], name: "index_blocked_on_customer_and_supplier", unique: true
    t.index ["customer_id"], name: "index_blocked_suppliers_on_customer_id"
    t.index ["supplier_id"], name: "index_blocked_suppliers_on_supplier_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "commission_payments", force: :cascade do |t|
    t.bigint "commission_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "payment_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commission_id"], name: "index_commission_payments_on_commission_id"
  end

  create_table "commissions", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.decimal "total_commission", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "paid_in_full", default: false, null: false
    t.index ["purchase_order_id"], name: "index_commissions_on_purchase_order_id", unique: true
  end

  create_table "customized_products", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "product_id", null: false
    t.string "custom_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customized_products_on_customer_id"
    t.index ["product_id"], name: "index_customized_products_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "generic_name"
    t.string "brand"
    t.string "unit_options", default: [], array: true
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.bigint "purchase_order_id", null: false
    t.bigint "product_id", null: false
    t.string "unit"
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0"
    t.decimal "price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.date "expiration_date"
    t.string "status", default: "aberta", null: false
    t.decimal "total_value", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "customer_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "quotation_id", null: false
    t.index ["customer_id"], name: "index_purchase_orders_on_customer_id"
    t.index ["quotation_id"], name: "index_purchase_orders_on_quotation_id"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
  end

  create_table "quotation_items", force: :cascade do |t|
    t.bigint "quotation_id", null: false
    t.bigint "product_id", null: false
    t.decimal "quantity", null: false
    t.string "selected_unit", null: false
    t.boolean "keep_generic_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_comment"
    t.index ["product_id"], name: "index_quotation_items_on_product_id"
    t.index ["quotation_id"], name: "index_quotation_items_on_quotation_id"
  end

  create_table "quotation_response_items", force: :cascade do |t|
    t.bigint "quotation_response_id", null: false
    t.bigint "quotation_item_id", null: false
    t.boolean "available", default: true, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quotation_item_id"], name: "index_quotation_response_items_on_quotation_item_id"
    t.index ["quotation_response_id"], name: "index_quotation_response_items_on_quotation_response_id"
  end

  create_table "quotation_responses", force: :cascade do |t|
    t.bigint "quotation_id", null: false
    t.bigint "supplier_id", null: false
    t.string "status", default: "aberta", null: false
    t.date "expiration_date"
    t.string "analysis_status", default: "aberta", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "supplier_snapshot"
    t.text "admin_feedback"
    t.index ["quotation_id"], name: "index_quotation_responses_on_quotation_id"
    t.index ["supplier_id"], name: "index_quotation_responses_on_supplier_id"
  end

  create_table "quotations", force: :cascade do |t|
    t.date "expiration_date", null: false
    t.bigint "customer_id", null: false
    t.string "status", default: "aberta", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "general_comment"
    t.string "title"
    t.jsonb "customer_snapshot"
    t.date "response_expiration_date", null: false
    t.index ["customer_id"], name: "index_quotations_on_customer_id"
  end

  create_table "signatures", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_signatures_on_user_id"
  end

  create_table "supplier_categories", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_supplier_categories_on_category_id"
    t.index ["supplier_id"], name: "index_supplier_categories_on_supplier_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "role", null: false
    t.string "cnpj", null: false
    t.string "responsible", null: false
    t.text "address", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "trade_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blocked_suppliers", "users", column: "customer_id"
  add_foreign_key "blocked_suppliers", "users", column: "supplier_id"
  add_foreign_key "commission_payments", "commissions"
  add_foreign_key "commissions", "purchase_orders"
  add_foreign_key "customized_products", "products"
  add_foreign_key "customized_products", "users", column: "customer_id"
  add_foreign_key "products", "categories"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "quotations"
  add_foreign_key "purchase_orders", "users", column: "customer_id"
  add_foreign_key "purchase_orders", "users", column: "supplier_id"
  add_foreign_key "quotation_items", "products"
  add_foreign_key "quotation_items", "quotations"
  add_foreign_key "quotation_response_items", "quotation_items"
  add_foreign_key "quotation_response_items", "quotation_responses"
  add_foreign_key "quotation_responses", "quotations"
  add_foreign_key "quotation_responses", "users", column: "supplier_id"
  add_foreign_key "quotations", "users", column: "customer_id"
  add_foreign_key "signatures", "users"
  add_foreign_key "supplier_categories", "categories"
  add_foreign_key "supplier_categories", "users", column: "supplier_id"
end
