class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items
  has_many :order_items

  enum :status, {
    active: 0,
    inactive: 0
  }, prefix: true
end
