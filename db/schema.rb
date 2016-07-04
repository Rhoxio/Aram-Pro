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

ActiveRecord::Schema.define(version: 20160625140335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "championbases", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "champion_identifier"
    t.string   "blurb"
    t.string   "image"
    t.string   "riot_tags",                                     array: true
    t.integer  "rating",              default: 0
    t.string   "other_tags",          default: [],              array: true
    t.text     "stats"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "champions", force: :cascade do |t|
    t.string   "champion_identifier"
    t.string   "championbase_id"
    t.string   "name"
    t.string   "runes",                            array: true
    t.string   "masteries",                        array: true
    t.string   "summoner_spells",                  array: true
    t.string   "summoner_identifier"
    t.string   "team"
    t.string   "image"
    t.integer  "match_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "champions", ["match_id"], name: "index_champions_on_match_id", using: :btree

  create_table "matches", force: :cascade do |t|
    t.string   "match_id",    null: false
    t.string   "platform_id"
    t.string   "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "summoners", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "level"
    t.string   "summoner_id"
    t.integer  "icon_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "summoners", ["user_id"], name: "index_summoners_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "summoner"
    t.integer  "summoner_id"
    t.string   "summoner_icon"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
