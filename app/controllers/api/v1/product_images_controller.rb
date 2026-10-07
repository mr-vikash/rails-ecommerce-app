class Api::V1::ProductImagesController < ApplicationController
  include Authentication

  before_action :authenticate_user
  before_action :set_product
  before_action :set_product_image, only: [:destroy, :update]

  def index
    @product_images = @product.product_images.order(:position)

    render :index, status: :ok
  end

  def create
    @product_image = @product.product_images.new(position: params[:position])
    @product_image.image.attach(params[:image])

    if @product_image.save
      render :show, status: :created
    else
      render json: { 
        status: "error",
        error: @product_image.errors.full_error_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if params[:position].present?
      @product_image.position = params[:position]
    end

    if params[:image].present?
      @product_image.image.attach(params[:image])
    end

    if @product_image.save
      render :show, status: :created
    else
      render json: { 
        status: "error",
        error: @product_image.errors.full_error_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @product_image.destroy!

    render json: {
      status: "success",
      message: "Product Image deleted successfully!"
    }, status: :ok
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_image
    @product_image = @product.product_images.find(params[:id])
  end
end