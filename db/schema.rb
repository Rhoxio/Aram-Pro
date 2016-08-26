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

ActiveRecord::Schema.define(version: 20160811014016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "builds", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "champion_id"
    t.integer  "championbase_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "builds", ["champion_id"], name: "index_builds_on_champion_id", using: :btree
  add_index "builds", ["championbase_id"], name: "index_builds_on_championbase_id", using: :btree
  add_index "builds", ["item_id"], name: "index_builds_on_item_id", using: :btree

  create_table "championbases", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "champion_identifier"
    t.string   "blurb"
    t.string   "image"
    t.float    "score"
    t.float    "win_rate"
    t.float    "pick_rate"
    t.float    "KDA"
    t.string   "tier"
    t.integer  "rating",              default: 0
    t.string   "riot_tags",                                     array: true
    t.string   "build_tags",          default: [],              array: true
    t.string   "playstyle_tags",      default: [],              array: true
    t.text     "stats"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "champions", force: :cascade do |t|
    t.string   "champion_identifier"
    t.string   "championbase_id"
    t.string   "summoner_id"
    t.string   "name"
    t.string   "summoner_identifier"
    t.string   "team"
    t.string   "masteries",                              array: true
    t.string   "summoner_spells",                        array: true
    t.string   "runes",                                  array: true
    t.string   "image"
    t.text     "postgame_stats"
    t.boolean  "won"
    t.integer  "gold_earned"
    t.integer  "damage_dealt_to_champions"
    t.integer  "total_damage_dealt"
    t.integer  "damage_taken"
    t.integer  "kills"
    t.integer  "deaths"
    t.integer  "assists"
    t.integer  "level"
    t.integer  "healing_done"
    t.integer  "match_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "champions", ["match_id"], name: "index_champions_on_match_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "item_identifier"
    t.string   "name"
    t.string   "image"
    t.string   "description"
    t.string   "short_description"
    t.string   "group"
    t.string   "tags",                                           array: true
    t.boolean  "aram_item",         default: false
    t.integer  "build_depth"
    t.text     "gold"
    t.text     "stats"
    t.text     "effect"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "matches", force: :cascade do |t|
    t.string   "match_id",         null: false
    t.string   "platform_id"
    t.string   "user_id"
    t.string   "match_created_at"
    t.boolean  "completed"
    t.text     "winrates"
    t.text     "scores"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "matchups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "runes", force: :cascade do |t|
    t.string   "rune_identifier"
    t.string   "name"
    t.string   "description"
    t.string   "image"
    t.string   "rune_type"
    t.integer  "tier"
    t.text     "stats"
    t.string   "tags",                         array: true
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "summoners", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "level"
    t.string   "summoner_identifier"
    t.integer  "icon_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
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
