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

ActiveRecord::Schema.define(version: 2019_07_31_175007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.jsonb "correios_settings", default: {}
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
    t.jsonb "azul_settings", default: {}
    t.integer "company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "token"
    t.string "name"
    t.index ["token"], name: "index_companies_on_token"
  end

  create_table "histories", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "user_id"
    t.string "changed_by"
    t.string "description"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "shipments", force: :cascade do |t|
    t.string "status", default: "pending"
    t.datetime "shipped_at"
    t.string "shipment_number"
    t.string "order_number"
    t.float "cost"
    t.string "carrier_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_series"
    t.integer "invoice_number"
    t.string "country"
    t.integer "account_id"
    t.string "shipping_method"
    t.string "tracking_number"
    t.jsonb "settings", default: {}
    t.xml "invoice_xml"
    t.integer "company_id"
    t.boolean "sent_to_carrier", default: false
    t.string "state"
    t.string "city_code"
    t.string "city"
    t.string "zip"
    t.string "neighborhood"
    t.string "complement"
    t.string "number"
    t.string "street"
    t.string "cpf"
    t.string "phone"
    t.string "email"
    t.string "last_name"
    t.string "first_name"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
