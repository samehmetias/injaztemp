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

ActiveRecord::Schema.define(version: 20150303002426) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "name"
    t.date     "event_start_at"
    t.date     "event_end_at"
    t.date     "job_start_at"
    t.date     "job_end_at"
    t.string   "job_number"
    t.string   "client_id"
    t.string   "description"
    t.integer  "user_id"
    t.string   "lead"
    t.boolean  "quoted",         default: false, null: false
    t.text     "notes"
    t.boolean  "deleted",        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_days", force: true do |t|
    t.integer  "job_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", force: true do |t|
    t.integer  "event_id"
    t.integer  "role_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_events", force: true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "role_id"
    t.integer  "rate"
    t.integer  "number_of_days"
    t.integer  "rating"
    t.boolean  "confirmed",      default: false, null: false
    t.boolean  "denied",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_jobs", force: true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.string   "status"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_languages", force: true do |t|
    t.integer  "user_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "",        null: false
    t.string   "nationality"
    t.string   "country_of_residence"
    t.string   "encrypted_password",     default: "",        null: false
    t.boolean  "is_admin",               default: false,     null: false
    t.boolean  "is_free_lancer",         default: false,     null: false
    t.string   "status",                 default: "Invited", null: false
    t.boolean  "active",                 default: true,      null: false
    t.string   "phone_number"
    t.string   "gender"
    t.integer  "job_count"
    t.integer  "day_rate"
    t.integer  "hour_rate"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
