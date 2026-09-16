class CreateWishListItems < ActiveRecord::Migration[7.2]
  def change
    create_table :wishlist_items do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :wishlist_items, [:wishlist_id, :product_id], unique: true
  end
end
