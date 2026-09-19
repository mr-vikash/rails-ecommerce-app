class Api::V1::CartsController < ApplicationController
  include Authentication

  def show
    @cart = current_user.cart
  end

    def clear
      @cart = current_user.cart

      if @cart.cart_items.destroy_all
        render json: {message: "Cart items deleted successfully"}, status: :ok
      else
        render json: {error: "Cart items not deleted"}, status: :ok
      end
    end
end
