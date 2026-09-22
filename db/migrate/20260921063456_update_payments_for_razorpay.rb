class UpdatePaymentsForRazorpay < ActiveRecord::Migration[7.2]
  def up
    # Allow transaction_id to be empty initially.
    change_column_null :payments, :transaction_id, true

    # Rename old status temporarily.
    rename_column :payments, :status, :status_string

    # Create integer status column.
    add_column :payments, :status, :integer, default: 0, null: false

    # Convert existing status values.
    execute <<~SQL
      UPDATE payments
      SET status = CASE status_string
        WHEN 'pending' THEN 0
        WHEN 'paid' THEN 1
        WHEN 'failed' THEN 2
        WHEN 'refunded' THEN 3
        ELSE 0
      END
    SQL

    # Remove old string column.
    remove_column :payments, :status_string

    # Razorpay fields.
    add_column :payments, :razorpay_order_id, :string
    add_column :payments, :razorpay_payment_id, :string
    add_column :payments, :razorpay_signature, :string

    # Indexes.
    add_index :payments, :razorpay_order_id, unique: true
    add_index :payments, :razorpay_payment_id, unique: true
  end

  def down
    # Remove Razorpay indexes.
    remove_index :payments, :razorpay_order_id
    remove_index :payments, :razorpay_payment_id

    # Remove Razorpay columns.
    remove_column :payments, :razorpay_order_id
    remove_column :payments, :razorpay_payment_id
    remove_column :payments, :razorpay_signature

    # Convert integer status back to string.
    rename_column :payments, :status, :status_integer

    add_column :payments, :status, :string, default: "pending", null: false

    execute <<~SQL
      UPDATE payments
      SET status = CASE status_integer
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'failed'
        WHEN 3 THEN 'refunded'
        ELSE 'pending'
      END
    SQL

    remove_column :payments, :status_integer

    change_column_null :payments, :transaction_id, false
  end
end
