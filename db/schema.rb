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

ActiveRecord::Schema.define(version: 20140413180205) do

  create_table "activities", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "user_id"
    t.string   "name"
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "assignments", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "due_time"
    t.integer  "point_value"
    t.text     "expected_output"
    t.text     "input"
    t.integer  "max_attempts"
    t.integer  "grace_period"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "submission_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["submission_id"], name: "index_comments_on_submission_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "courses", force: true do |t|
    t.string   "name"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "language",    default: "Ruby"
    t.string   "enroll_key"
  end

  create_table "courses_users", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "user_id"
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

  create_table "source_files", force: true do |t|
    t.integer  "submission_id"
    t.boolean  "main"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code_file_name"
    t.string   "code_content_type"
    t.integer  "code_file_size"
    t.datetime "code_updated_at"
  end

  add_index "source_files", ["submission_id"], name: "index_source_files_on_submission_id", using: :btree

  create_table "submissions", force: true do |t|
    t.integer  "assignment_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "grade"
    t.text     "output"
    t.string   "status"
    t.text     "plagiarizing"
    t.integer  "num_attempts"
    t.integer  "max_attempts_override"
    t.datetime "last_submitted_at"
    t.datetime "last_graded_at"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "teacher",                default: false
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
