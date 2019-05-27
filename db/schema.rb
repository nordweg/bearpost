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

ActiveRecord::Schema.define(version: 20190527174751) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.jsonb "correios_settings", default: {}
  end

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.integer "shipment_id"
    t.string "tracking_number"
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
    t.string "status"
    t.datetime "shipped_at"
    t.string "shipment_number"
    t.string "order_number"
    t.float "cost"
    t.string "carrier_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_series"
    t.integer "invoice_number"
    t.string "sender_first_name"
    t.string "sender_last_name"
    t.string "sender_email"
    t.string "sender_phone"
    t.string "sender_cpf"
    t.string "sender_street"
    t.string "sender_number"
    t.string "sender_complement"
    t.string "sender_neighborhood"
    t.string "sender_cep"
    t.string "sender_city"
    t.string "sender_city_code"
    t.string "sender_state"
    t.string "recipient_first_name"
    t.string "recipient_last_name"
    t.string "recipient_email"
    t.string "recipient_phone"
    t.string "recipient_cpf"
    t.string "recipient_street"
    t.string "recipient_number"
    t.string "recipient_complement"
    t.string "recipient_neighborhood"
    t.string "recipient_cep"
    t.string "recipient_city"
    t.string "recipient_city_code"
    t.string "recipient_state"
    t.string "sender_country"
    t.string "recipient_country"
    t.integer "account_id"
    t.string "shipping_method"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
