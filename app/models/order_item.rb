class OrderItem < ApplicationRecord 
  belongs_to :order
  belongs_to :product_variant

  validates :product_name, :sku, :quantity, :unit_price, :total_price,
            presence: true

  validates :quantity, numericality: { greater_than: 0 }

  validates :unit_price, :total_price,
            numericality: { greater_than_or_equal_to: 0 }
end
