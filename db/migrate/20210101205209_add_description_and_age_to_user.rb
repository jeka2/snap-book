class AddDescriptionAndAgeToUser < ActiveRecord::Migration
  def change
    add_column :users, :info, :string, :default => "User has not provided any information about themselves"
    add_column :users, :age, :integer
  end
end

