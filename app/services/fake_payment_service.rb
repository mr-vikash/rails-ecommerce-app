class FakePaymentService
  def self.create_order(amount:, receipt:)
    {
      id: "fake_order_#{SecureRandom.hex(6)}",
      amount: (amount.to_f * 100).to_i,
      currency: "INR",
      receipt: receipt,
      status: "created"
    }
  end

  def self.capture_payment(order_id:, amount:)
    {
      id: "fake_payment_#{SecureRandom.hex(6)}",
      order_id: order_id,
      amount: (amount.to_f * 100).to_i,
      currency: "INR",
      status: "captured"
    }
  end

  def self.verify_payment(
    order_id:,
    payment_id:,
    signature:
  )
    return false if order_id.blank?
    return false if payment_id.blank?
    return false if signature.blank?

    true
  end
end