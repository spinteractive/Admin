class AddPaymentSuccessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :payment_success, :boolean
  end
end
