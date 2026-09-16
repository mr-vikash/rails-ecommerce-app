class Coupan < ApplicationRecord
  has_many :order_coupons, dependent: :destroy
  has_many :orders, through: :order_coupons

  enum :discount_type, {
    percentage: 0,
    fixed: 1
  }, prefix: true

  validates :code, presence: true, uniqueness: true
  validates :discount_value, numericality: { greater_than: 0 }
end
