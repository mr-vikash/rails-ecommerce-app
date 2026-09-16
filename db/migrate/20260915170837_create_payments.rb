class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.string :transaction_id, null: false
      t.integer :payment_method, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "INR"
      t.string :status, null: false, default: "pending"
      t.datetime :paid_at

      t.timestamps
    end

    add_index :payments, :transaction_id, unique: true
  end
end
