class AddGoogleIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :google_id, :string
  end
end
