class Api::V1::OrdersController < ApplicationController
  include Authentication

  def index
    @orders = current_user.orders.order(created_at: :desc)
    unless @orders
      render json: { error: "no orders for this user" }, status: :not_found
    end
  end

  def show
    @order = Order.includes(order_items: { product_variant: :product } ).find_by(id: params[:id])

    unless @order
      render json: { error: "Order not found"}, status: :not_found
    end
  end

  def create
    @cart = current_user.cart

    unless @cart
      render json: {error: "Cart not exist for this user"}, status: :not_found
      return
    end

    @cart_items = @cart.cart_items
    if @cart_items.empty?
      render json: {error: "Cart is Empty"}, status: :unprocessable_entity
      return
    end

    Order.transaction do
      #stock check
      @cart_items.each do |cart_item|
        variant = cart_item.product_variant
        if cart_item.quantity > variant.stock_quantity
          raise StandardError, "Insufficien stock for #{variant.sku}"
        end
      end

      #calculate sub total
      subtotal = 0
      @cart_items.each do |cart_item|
        subtotal += cart_item.quantity*cart_item.unit_price
      end



      Rails.logger.info("Someting happening..")

      #create_order
       @order = current_user.orders.create!(
        order_number: "ORD-#{SecureRandom.hex(5).upcase}",
        status: "pending",
        payment_status: "pending",
        subtotal: subtotal,
        discount: 0,
        tax: 0,
        shipping_charge: 0,
        total_amount: subtotal,
        placed_at: Time.current
      )

      #create_order_item
      @cart_items.each do |cart_item|
        variant = cart_item.product_variant
        product = variant.product

        OrderItem.create!(
          order_id: @order.id,
          product_variant_id: variant.id,
          product_name: product.name,
          sku: variant.sku,
          quantity: cart_item.quantity,
          unit_price: cart_item.unit_price,
          total_price: cart_item.quantity * cart_item.unit_price
        )

        variant.decrement!(:stock_quantity, cart_item.quantity)
      end
      @cart_items.destroy_all
    end

    render json: {
      status: "success",
      message: "Order created successfully",
      order: {
        id: @order.id,
        order_number: @order.order_number,
        status: @order.status,
        payment_status: @order.payment_status,
        subtotal: @order.subtotal,
        discount: @order.discount,
        tax: @order.tax,
        shipping_charge: @order.shipping_charge,
        total_amount: @order.total_amount,
        placed_at: @order.placed_at
      }
    }, status: :created
  
  rescue StandardError => e
    render json: {
      status: "error",
      message: e.message
    }, status: :unprocessable_entity
  end

  def checkout
    @order = current_user.orders.find(params[:id])

    @order.with_lock do
      if @order.payments.status_paid.exists?
        return render json: {
          status: "error",
          message: "Order has already been paid"
        }, status: :unprocessable_entity
      end

      if @order.payments.status_pending.exists?
        return render json: {
          status: "error",
          message: "A payment is already in progress for this order"
        }, status: :unprocessable_entity
      end

      razorpay_order = RazorpayService.create_order(
        amount: @order.total_amount,
        receipt: "order_#{@order.id}"
      )

      payment = @order.payments.create!(
        user: current_user,
        transaction_id: "pending_#{SecureRandom.uuid}",
        payment_method: :razorpay,
        amount: @order.total_amount,
        currency: "INR",
        status: "pending",
        razorpay_order_id: razorpay_order.id
      )

      render json: {
        status: "success",
        message: "Checkout initialized successfully",
        order: {
          id: @order.id,
          total_amount: @order.total_amount,
          status: @order.status
        },
        payment: {
          id: payment.id,
          razorpay_order_id: razorpay_order.id,
          amount: payment.amount,
          currency: payment.currency,
          status: payment.status
        },
        razorpay: {
          key_id: ENV["RAZORPAY_KEY_ID"]
        }
      }
    end
  end
end