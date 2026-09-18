class Api::V1::ProductVariantsController < ApplicationController
  include Authentication

  before_action :set_product_variant, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user, only: [:index, :show]
  
  def index
    @product_variants = ProductVariant.all
  end

  def create
    @product_variant = ProductVariant.new(variant_params)
    if @product_variant.save
      render :show, status: :created
    else
      render json: { error: @product_variant.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    unless @product_variant
      render json: { error: "Product variant not found"}, status: :unprocessable_entity
    end
    if @product_variant.update(variant_params)
      render :show, status: :ok
    else
      render json: { error: @product_variant.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    unless @product_variant
      render json: { error: "Product variant not found"}, status: :unprocessable_entity
    end
  
    @product_variant.destroy
    render json: {message: "Product variant deleted successfully"}, status: :ok
  end

  private

  def set_product_variant
    @product_variant = ProductVariant.find(params[:id])
  end

  def variant_params
    params.require(:product_variant).permit(
      :product_id,
      :sku,
      :price,
      :stock_quantity,
      :size,
      :color,
      :status
    )
  end

end