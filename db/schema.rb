# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151003182328) do

  create_table "amazon_accounts", force: :cascade do |t|
    t.integer  "shop_id"
    t.string   "seller_id"
    t.string   "marketplace_id"
    t.string   "mws_auth_token"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "amazon_accounts", ["shop_id"], name: "index_amazon_accounts_on_shop_id"

  create_table "shops", force: :cascade do |t|
    t.text     "domain"
    t.text     "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shops", ["domain"], name: "index_shops_on_domain"

end
