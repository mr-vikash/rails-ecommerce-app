class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.integer :rating, null: false
      t.string :title
      t.text :comment
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :reviews, [:user_id, :product_id, :order_id], unique: true
  end
end
