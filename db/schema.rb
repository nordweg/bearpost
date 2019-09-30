# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_29_122204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "cnpj"
    t.string "razao_social"
    t.string "inscricao_estadual"
    t.string "phone"
    t.string "email"
    t.string "street"
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "city"
    t.string "zip"
    t.string "state"
    t.string "country"
    t.integer "company_id"
  end

  create_table "carrier_settings", force: :cascade do |t|
    t.integer "account_id"
    t.string "carrier_class"
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "histories", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "user_id"
    t.string "changed_by"
    t.string "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.string "city"
    t.string "state"
    t.string "bearpost_status"
    t.string "carrier_status_code"
  end

  create_table "packages", force: :cascade do |t|
    t.integer "shipment_id"
    t.float "heigth"
    t.float "width"
    t.float "depth"
    t.float "weight"
    t.float "items_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reverse_shipments", force: :cascade do |t|
    t.string "authorization_code"
    t.string "authorization_code_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.string "status", default: "pending"
    t.datetime "shipped_at"
    t.string "shipment_number"
    t.string "order_number"
    t.float "cost"
    t.string "carrier_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_series"
    t.integer "invoice_number"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "cpf"
    t.string "street"
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "zip"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "account_id"
    t.string "shipping_method"
    t.string "tracking_number"
    t.jsonb "settings", default: {}
    t.xml "invoice_xml"
    t.integer "company_id"
    t.boolean "sent_to_carrier", default: false
    t.datetime "last_synched_at"
    t.datetime "ready_for_shipping_at"
    t.datetime "delivered_at"
    t.datetime "approved_at"
    t.integer "handling_days_planned"
    t.integer "handling_days_used"
    t.integer "handling_days_delayed"
    t.datetime "shipping_due_at"
    t.integer "carrier_delivery_days_planned"
    t.integer "carrier_delivery_days_used"
    t.integer "carrier_delivery_days_delayed"
    t.datetime "carrier_delivery_due_at"
    t.integer "client_delivery_days_planned"
    t.integer "client_delivery_days_used"
    t.integer "client_delivery_days_delayed"
    t.datetime "client_delivery_due_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
