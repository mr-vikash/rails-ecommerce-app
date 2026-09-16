class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  has_many :payments, dependent: :destroy
  has_many :order_coupons, dependent: :destroy
  has_many :coupons, through: :order_coupons

  validates :order_number, presence: true, uniqueness: true
  validates :subtotal, :discount, :tax, :shipping_charge, :total_amount,
            numericality: { greater_than_or_equal_to: 0 }
end
