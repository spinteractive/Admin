class AddSubscriptionTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_token, :string
  end
end
