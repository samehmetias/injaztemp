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

ActiveRecord::Schema.define(version: 20160818183908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: true do |t|
    t.string   "key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "implementer_requests", force: true do |t|
    t.string   "classroom",  default: ""
    t.datetime "start_date"
    t.integer  "duration",   default: 0
    t.integer  "school_id",  default: 0,         null: false
    t.integer  "user_id",    default: 0,         null: false
    t.integer  "program_id", default: 0,         null: false
    t.string   "status",     default: "pending"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "lessons", force: true do |t|
    t.string   "name",                   default: "",        null: false
    t.datetime "date"
    t.integer  "implementer_request_id", default: 0,         null: false
    t.string   "status",                 default: "pending", null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "phones", force: true do |t|
    t.integer  "user_id",    default: 0,     null: false
    t.string   "token",      default: "",    null: false
    t.string   "uuid",       default: "",    null: false
    t.boolean  "is_android", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programs", force: true do |t|
    t.string   "name",         default: "", null: false
    t.integer  "duration",     default: 0,  null: false
    t.string   "participants", default: "", null: false
    t.string   "overview",     default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "schools", force: true do |t|
    t.string   "name",         default: "", null: false
    t.string   "district",     default: "", null: false
    t.integer  "prep_classes", default: 0,  null: false
    t.integer  "sec_classes",  default: 0,  null: false
    t.integer  "uni_classes",  default: 0,  null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: true do |t|
    t.string   "name",                   default: "",    null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "telephone",              default: "",    null: false
    t.string   "work_type",              default: "",    null: false
    t.string   "area_residence",         default: "",    null: false
    t.string   "service_area",           default: "",    null: false
    t.string   "coordination_skills",    default: "",    null: false
    t.string   "implementation_skills",  default: "",    null: false
    t.float    "appraisal_grade",        default: 0.0,   null: false
    t.string   "employee_type",          default: "",    null: false
    t.boolean  "admin",                  default: false, null: false
    t.integer  "company_id",             default: 0,     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
