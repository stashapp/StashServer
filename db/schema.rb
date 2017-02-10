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

ActiveRecord::Schema.define(version: 20170123195042) do

  create_table "galleries", force: :cascade do |t|
    t.string   "title"
    t.string   "path"
    t.string   "checksum"
    t.string   "ownable_type"
    t.integer  "ownable_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["ownable_type", "ownable_id"], name: "index_galleries_on_ownable_type_and_ownable_id"
  end

  create_table "galleries_performers", id: false, force: :cascade do |t|
    t.integer "gallery_id"
    t.integer "performer_id"
    t.index ["gallery_id"], name: "index_galleries_performers_on_gallery_id"
    t.index ["performer_id"], name: "index_galleries_performers_on_performer_id"
  end

  create_table "performers", force: :cascade do |t|
    t.binary   "image",      limit: 2097152
    t.string   "checksum"
    t.string   "name"
    t.string   "url"
    t.string   "twitter"
    t.date     "birthdate"
    t.string   "ethnicity"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "performers_scenes", id: false, force: :cascade do |t|
    t.integer "performer_id"
    t.integer "scene_id"
    t.index ["performer_id"], name: "index_performers_scenes_on_performer_id"
    t.index ["scene_id"], name: "index_performers_scenes_on_scene_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.string   "title"
    t.string   "details"
    t.string   "url"
    t.date     "date"
    t.integer  "rating"
    t.string   "path"
    t.string   "checksum"
    t.integer  "studio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_scenes_on_path", unique: true
    t.index ["studio_id"], name: "index_scenes_on_studio_id"
  end

  create_table "studios", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.integer  "tag_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

end
