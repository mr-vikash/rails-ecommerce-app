class Api::V1::CartsController < ApplicationController
  include Authentication

  def show
    @cart = current_user.cart
  end
end
