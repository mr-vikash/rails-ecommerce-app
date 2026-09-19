class Api::V1::CartItemsController < ApplicationController
  include Authentication

  def show
    @cart_item = CartItem.find(params[:id])

    unless @cart_item
      render json: { error: "Cart item not exist"}, status: :not_found
    end
  end

  def create
    @cart = current_user.cart

    @product_variant = ProductVariant.find_by(id: cart_item_params[:product_variant_id])

    unless @product_variant
      render json: { error: "Product not found"}, status: :not_found
      return
    end

    @cart_item = @cart.cart_items.find_or_initialize_by(product_variant_id: @product_variant.id)
    @cart_item.quantity = (@cart_item.quantity || 0 ) +  cart_item_params[:quantity].to_i
    @cart_item.unit_price = cart_item_params[:unit_price]
    @cart_item.cart_id = @cart.id

    if @cart_item.save
      render :show, status: :created
    else
      render json: {error: @cart_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @cart_item = CartItem.find_by(id: params[:id])

    unless @cart_item
      render json: { error: "Cart item not found"}, status: :not_found
      return
    end

    @cart_item.quantity = cart_item_params[:quantity]

    if @cart_item.save
      render :show, status: :ok
    else
      render json: { error: @cart_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = CartItem.find_by(id: params[:id])

    unless @cart_item
      render json: { error: "Cart item not found"}, status: :not_found
      return
    end

    if @cart_item.destroy
      render json: { message: "Cartitem deleted successfully"}, status: :ok
    else
      render json: { error: "cart item not deleted"}, status: :unprocessable_entity
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(
                              :product_variant_id,
                              :quantity,
                              :unit_price
                            )
  end
end
