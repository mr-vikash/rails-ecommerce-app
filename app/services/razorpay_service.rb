class RazorpayService
  def self.create_order(amount:, receipt:, currency: "INR")
    Razorpay::Order.create(
      amount: (amount * 100).to_i,
      currency: currency,
      receipt: receipt,
      payment_capture: 1
    )
  end
end