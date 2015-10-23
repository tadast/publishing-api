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

ActiveRecord::Schema.define(version: 20151023125128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "draft_content_items", force: :cascade do |t|
    t.string   "content_id"
    t.string   "locale"
    t.integer  "version",           default: 0,  null: false
    t.string   "base_path"
    t.string   "title"
    t.string   "description"
    t.string   "format"
    t.datetime "public_updated_at"
    t.json     "access_limited",    default: {}
    t.json     "metadata",          default: {}
    t.json     "details",           default: {}
    t.json     "routes",            default: []
    t.json     "redirects",         default: []
    t.string   "publishing_app"
    t.string   "rendering_app"
  end

  add_index "draft_content_items", ["content_id", "locale"], name: "index_draft_content_items_on_content_id_and_locale", unique: true, using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "action",                  null: false
    t.json     "payload",    default: {}, null: false
    t.string   "user_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link_sets", force: :cascade do |t|
    t.string  "content_id"
    t.integer "version",    default: 0,  null: false
    t.json    "links",      default: {}
  end

  add_index "link_sets", ["content_id"], name: "index_link_sets_on_content_id", unique: true, using: :btree

  create_table "live_content_items", force: :cascade do |t|
    t.string   "content_id"
    t.string   "locale"
    t.integer  "version",               default: 0,  null: false
    t.string   "base_path"
    t.string   "title"
    t.string   "description"
    t.string   "format"
    t.datetime "public_updated_at"
    t.json     "metadata",              default: {}
    t.json     "details",               default: {}
    t.json     "routes",                default: []
    t.json     "redirects",             default: []
    t.string   "publishing_app"
    t.string   "rendering_app"
    t.integer  "draft_content_item_id",              null: false
  end

  add_index "live_content_items", ["content_id", "locale"], name: "index_live_content_items_on_content_id_and_locale", unique: true, using: :btree
  add_index "live_content_items", ["draft_content_item_id"], name: "index_live_content_items_on_draft_content_item_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.integer  "target_id",               null: false
    t.string   "target_type",             null: false
    t.integer  "number",      default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_foreign_key "live_content_items", "draft_content_items"
end
