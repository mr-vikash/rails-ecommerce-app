class CreateCoupans < ActiveRecord::Migration[7.2]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.decimal :minimum_order_amount, precision: 10, scale: 2, default: 0
      t.decimal :maximum_discount, precision: 10, scale: 2
      t.datetime :starts_at
      t.datetime :expires_at
      t.integer :usage_limit
      t.integer :used_count, null: false, default: 0
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
