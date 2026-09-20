class Api::V1::OrdersController < ApplicationController
  include Authentication

  def create
    @cart = current_user.cart

    unless @cart
      render json: {error: "Cart not exist for this user"}, status: :not_found
      return
    end

    @cart_items = @cart.cart_items
    unless @cart
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
end