class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :isbn
      t.string :image
      t.string :description
      t.integer :author_id
      t.integer :user_id
    end
  end
end
