class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image
  validates :image, presence: true
end
