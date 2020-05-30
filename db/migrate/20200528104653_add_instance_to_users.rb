class AddInstanceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :instance, :string
  end
end
