class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user

  def razorpay
    payload = request.raw_post
    signature = request.headers["X-Razorpay-Signature"]

    begin
      Razorpay::Utility.verify_webhook_signature(
        payload,
        signature,
        ENV["RAZORPAY_WEBHOOK_SECRET"]
      )
    rescue Razorpay::SignatureVerificationError
      return render json: {
        status: "error",
        message: "Invalid webhook signature"
      }, status: :unauthorized
    end

    event = JSON.parse(payload)

    case event["event"]
    when "payment.captured"
      handle_payment_captured(event)

    when "payment.failed"
      handle_payment_failed(event)

    when "refund.created"
      handle_refund_created(event)

    when "refund.processed"
      handle_refund_processed(event)

    when "refund.failed"
      handle_refund_failed(event)
    end

    render json: {
      status: "success",
      message: "Webhook received"
    }, status: :ok
  end

  private

  def handle_payment_captured(event)
    payment_entity = event.dig(
      "payload",
      "payment",
      "entity"
    )

    razorpay_order_id = payment_entity["order_id"]
    razorpay_payment_id = payment_entity["id"]

    payment = Payment.find_by(
      razorpay_order_id: razorpay_order_id
    )

    return unless payment

    return if payment.status_paid?

    Payment.transaction do
      payment.update!(
        status: :paid,
        transaction_id: razorpay_payment_id,
        razorpay_payment_id: razorpay_payment_id,
        paid_at: Time.current
      )

      payment.order.update!(
        payment_status: "paid"
      )
    end
  end

  def handle_payment_failed(event)
    payment_entity = event.dig(
      "payload",
      "payment",
      "entity"
    )

    razorpay_order_id = payment_entity["order_id"]

    payment = Payment.find_by(
      razorpay_order_id: razorpay_order_id
    )

    return unless payment
    return if payment.status_paid?

    payment.update!(
      status: :failed
    )
  end

  def handle_refund_created(event)
    Rails.logger.info("Razorpay refund created")
  end

  def handle_refund_processed(event)
    Rails.logger.info("Razorpay refund processed")
  end

  def handle_refund_failed(event)
    Rails.logger.info("Razorpay refund failed")
  end
end