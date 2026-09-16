class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true

      t.string :order_number, null: false
      t.string :status, null: false, default: "pending"
      t.string :payment_status, null: false, default: "pending"

      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :discount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax, precision: 10, scale: 2, null: false, default: 0
      t.decimal :shipping_charge, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0

      t.datetime :placed_at

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
  end
end
