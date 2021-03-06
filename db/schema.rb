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

ActiveRecord::Schema.define(version: 20210107180334) do

  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.string "gender"
    t.string "description"
  end

  create_table "books", force: :cascade do |t|
    t.string  "title"
    t.string  "isbn"
    t.string  "image"
    t.string  "description"
    t.integer "author_id"
    t.integer "user_id"
    t.string  "google_id"
    t.string  "authors"
    t.string  "publisher"
    t.integer "page_count"
    t.string  "categories"
    t.integer "average_rating"
    t.integer "ratings_count"
    t.string  "info_link"
  end

  create_table "user_books", force: :cascade do |t|
    t.integer "user_id"
    t.integer "book_id"
  end

  create_table "users", force: :cascade do |t|
    t.string  "username"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "info"
    t.integer "age"
    t.string  "password_hash"
    t.string  "image"
  end

end
