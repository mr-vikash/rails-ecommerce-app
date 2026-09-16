class CreateAddresses < ActiveRecord::Migration[7.2]
   def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true

      t.string :address_type
      t.string :full_name, null: false
      t.string :phone
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :city, null: false
      t.string :state, null: false
      t.string :country, null: false
      t.string :postal_code, null: false
      t.boolean :is_default, default: false

      t.timestamps
    end
  end
end
