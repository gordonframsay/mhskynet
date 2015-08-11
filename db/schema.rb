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

ActiveRecord::Schema.define(version: 20150718223934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "password"
    t.string   "email_address"
    t.integer  "active",        limit: 2, default: 0
    t.integer  "disabled",      limit: 2, default: 0
  end

  create_table "blocked_ips", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.cidr     "address"
    t.string   "reason"
  end

  create_table "cached_ips", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.cidr     "address"
    t.integer  "blocked",    limit: 2
    t.string   "reason"
  end

  create_table "hang_man_games", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phrase"
    t.string   "letters_guessed"
  end

  create_table "messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.integer  "author_id"
  end

  add_index "messages", ["author_id"], name: "messages_author_id_index", using: :btree

  create_table "queued_movies", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.string   "service"
    t.string   "title"
    t.string   "preview_image_url",            limit: 512
    t.datetime "start_time"
    t.integer  "duration"
    t.integer  "live_event",                   limit: 2,   default: 0
    t.cidr     "source_ip"
    t.text     "notes"
    t.string   "session_id"
    t.integer  "screening_room",                           default: 1
    t.binary   "marshalled_google_user_token"
  end

  create_table "radio_songs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.string   "service",    default: "youtube"
    t.string   "session_id"
    t.cidr     "source_ip"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "site_defaults", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key_name"
    t.text     "description"
    t.string   "key_value"
    t.string   "key_type"
  end

end
