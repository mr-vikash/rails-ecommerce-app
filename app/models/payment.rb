class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :order

  validates :transaction_id, presence: true, uniqueness: true
  validates :payment_method, :amount, :currency, presence: true
  validates :amount, numericality: { greater_than: 0 }

  enum :payment_method, {
    upi: 0,
    cash: 1
  }, prefix: true
end
