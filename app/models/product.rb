class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants
  has_many :reviews
  has_many :product_images
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlists, through: :wishlist_items
end
