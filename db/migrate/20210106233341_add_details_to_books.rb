class AddDetailsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :google_id, :string
    add_column :books, :authors, :string
    add_column :books, :publisher, :string
    add_column :books, :page_count, :integer
    add_column :books, :categories, :string
    add_column :books, :average_rating, :integer 
    add_column :books, :ratings_count, :integer
    add_column :books, :info_link, :string
  end
end
