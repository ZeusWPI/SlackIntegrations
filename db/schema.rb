# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2015_02_17_152728) do

  create_table "fuckers", force: :cascade do |t|
    t.integer "fuck_id", null: false
    t.string "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fucks", force: :cascade do |t|
    t.string "name"
    t.integer "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_fucks_on_name"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "token"
    t.string "team_id"
    t.string "channel_id"
    t.string "channel_name"
    t.string "user_id"
    t.string "user_name"
    t.string "command"
    t.text "text", limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
