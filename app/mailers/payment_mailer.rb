class PaymentMailer < ApplicationMailer
  def payment_success(payment)
    @payment = payment
    @order = payment.order
    @user = payment.user

    mail(
      to: @user.email,
      subject: "Payment Successful - Order ##{@order.id}"
    )
  end
end
