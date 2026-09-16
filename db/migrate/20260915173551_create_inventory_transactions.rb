class CreateInventoryTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_transactions do |t|
      t.references :product_variant, null: false, foreign_key: true

      t.string :transaction_type, null: false
      t.integer :quantity, null: false
      t.string :reference_type
      t.bigint :reference_id

      t.timestamps
    end

    add_index :inventory_transactions, [:reference_type, :reference_id]
  end
end
