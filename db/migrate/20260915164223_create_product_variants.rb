class CreateProductVariants < ActiveRecord::Migration[7.2]
  def change
    def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true

      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.string :size
      t.string :color
      t.string :status, default: "active"

      t.timestamps
    end

    add_index :product_variants, :sku, unique: true
  end
  end
end
