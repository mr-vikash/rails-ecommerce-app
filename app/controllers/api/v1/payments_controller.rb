class Api::V1::PaymentsController < ApplicationController
  include Authentication

  def verify
    razorpay_order_id = params[:razorpay_order_id]
    razorpay_payment_id = params[:razorpay_payment_id]
    razorpay_signature = params[:razorpay_signature]

    payment = Payment.find_by(razorpay_order_id: razorpay_order_id)

    unless payment
      render json: { error: "Payment not found"}, status: :not_found
      return
    end

    if payment.status_paid?
      render json: {error: "Already paid"}, status: :unprocessable_entity
      return
    end

    begin
      Razorpay::Utility.verify_payment_signature(
        razorpay_order_id: :razorpay_order_id,
        razorpay_payment_id: :razorpay_payment_id,
        razorpay_signature: :razorpay_signature
      )

      Payment.transaction do
        payment.update!(
          status: :paid,
          transaction_id: razorpay_payment_id,
          razorpay_payment_id: razorpay_payment_id,
          razorpay_signature: razorpay_signature,
          paid_at: Time.current
        )

        payment.order.update!(
          payment_status: :paid
        )
      end

        render json: {
        status: "success",
        message: "Payment verified successfully",
        payment: {
          id: payment.id,
          order_id: payment.order_id,
          razorpay_order_id: payment.razorpay_order_id,
          razorpay_payment_id: payment.razorpay_payment_id,
          amount: payment.amount,
          currency: payment.currency,
          status: payment.status,
          paid_at: payment.paid_at
        }
      }, status: :ok
    rescue StandardError => e
      payment.update!(status: :failed)
      render json: {
        status: "error",
        message: e.message,
      }, status: :unprocessable_entity
    end
  end
end