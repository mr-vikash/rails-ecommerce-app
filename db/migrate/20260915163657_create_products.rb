class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true

      t.string :name, null: false
      t.text :description
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :discount_price, precision: 10, scale: 2
      t.string :status, default: "active"
      t.string :brand
      t.decimal :weight, precision: 10, scale: 2

      t.timestamps
    end

    add_index :products, :sku, unique: true
  end
end
