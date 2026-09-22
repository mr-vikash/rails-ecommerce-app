class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :order

  validates :transaction_id, uniqueness: true, allow_nil: true
  validates :payment_method, :amount, :currency, presence: true
  validates :amount, numericality: { greater_than: 0 }

  enum :status, {
    pending: 0,
    paid: 1,
    failed: 2,
    refunded: 3
  }, prefix: true

  enum :payment_method, {
    razorpay: 0,
    upi: 1,
    cash: 2
  }, prefix: true

end
