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

ActiveRecord::Schema.define(version: 20150826220612) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "draft_content_items", force: :cascade do |t|
    t.string   "base_path"
    t.string   "content_id"
    t.string   "locale"
    t.string   "title"
    t.string   "description"
    t.string   "format"
    t.datetime "public_updated_at"
    t.json     "details",           null: false
    t.integer  "user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",       null: false
    t.json     "payload",    null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_content_item_versions", force: :cascade do |t|
    t.string   "content_id"
    t.integer  "version",           null: false
    t.string   "base_path"
    t.string   "locale"
    t.string   "title"
    t.string   "description"
    t.string   "format"
    t.datetime "public_updated_at"
    t.json     "details",           null: false
    t.integer  "user_id"
  end

  add_index "live_content_item_versions", ["content_id", "version"], name: "index_live_content_item_versions_on_content_id_and_version", unique: true, using: :btree

  create_table "live_content_items", force: :cascade do |t|
    t.string   "base_path"
    t.string   "content_id"
    t.string   "locale"
    t.string   "title"
    t.string   "description"
    t.string   "format"
    t.datetime "public_updated_at"
    t.json     "details",           null: false
    t.integer  "user_id"
    t.integer  "version",           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
  end

  add_foreign_key "draft_content_items", "users", on_delete: :restrict
  add_foreign_key "events", "users", on_delete: :restrict
  add_foreign_key "live_content_item_versions", "users", on_delete: :restrict
  add_foreign_key "live_content_items", "users", on_delete: :restrict
end