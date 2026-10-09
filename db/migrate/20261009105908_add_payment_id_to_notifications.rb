class AddPaymentIdToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :payment_id, :bigint
    add_index :notifications, :payment_id, unique: true
  end
end
