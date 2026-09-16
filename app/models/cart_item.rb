class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_variant

  validates :quantity, numaricality: {greater_than_or_equal_to: 0}
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
end
