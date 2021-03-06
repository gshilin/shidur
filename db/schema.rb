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

ActiveRecord::Schema.define(version: 20160214033639) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.string   "author"
    t.string   "book"
    t.integer  "page"
    t.string   "letter"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "book_name"
  end

  create_table "books", force: :cascade do |t|
    t.string   "author",     limit: 255
    t.string   "title",      limit: 255
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "slides"
  end

  create_table "gomigrate", force: :cascade do |t|
    t.integer "migration_id", limit: 8, null: false
  end

  add_index "gomigrate", ["migration_id"], name: "gomigrate_migration_id_key", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message",    default: ""
    t.string   "user_name",  default: ""
    t.string   "type",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",   default: "he"
    t.boolean  "approved",   default: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "question",    default: ""
    t.string   "user"
    t.boolean  "is_question", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.string   "to_email",     limit: 255
    t.datetime "created_at"
    t.string   "url",          limit: 255
    t.datetime "updated_at"
  end

end
