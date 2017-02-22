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

ActiveRecord::Schema.define(version: 20170112152157) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chapters", force: :cascade do |t|
    t.integer  "story_id"
    t.integer  "number"
    t.string   "title"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_chapters_on_story_id", using: :btree
  end

  create_table "documents", force: :cascade do |t|
    t.integer  "story_id"
    t.string   "filename"
    t.string   "extension"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "aws_url"
    t.string   "aws_key"
    t.index ["story_id"], name: "index_documents_on_story_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.integer  "story_id"
    t.string   "source_url"
    t.string   "aws_url"
    t.string   "filename"
    t.string   "extension"
    t.integer  "size"
    t.boolean  "cover"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "aws_key"
    t.index ["story_id"], name: "index_images_on_story_id", using: :btree
  end

  create_table "requests", force: :cascade do |t|
    t.integer  "story_id"
    t.string   "url"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "status"
    t.integer  "total_chapters"
    t.boolean  "complete"
    t.integer  "current_chapters"
    t.string   "extension"
    t.integer  "doc_id"
    t.string   "aws_url"
    t.index ["story_id"], name: "index_requests_on_story_id", using: :btree
  end

  create_table "scraper_queues", force: :cascade do |t|
    t.string   "domain"
    t.datetime "last_access"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "stories", force: :cascade do |t|
    t.string   "url"
    t.string   "title"
    t.string   "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "meta_data"
  end

end
