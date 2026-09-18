module Api
  module V1
    class ProductsController < ApplicationController
      include Authentication

      skip_before_action :authenticate_user, only: [:index, :show]

      def index
        @products = Product.all
      end

      def show
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Record not found"}, status: :not_found
      end

      def create
        @product = Product.new(product_params)
        if @product.save
          render :show, status: :created
        else
          render json: {errors: @product.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        @product = Product.find(params[:id])
        if @product.update(product_params)
          render :show, status: :ok
        else
          render json: { errors: @product.errors.full_messages}, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Record not found"}, status: :not_found
      end

      def destroy
        @product = Product.find(params[:id])
        if @product.destroy
          render json: {message: "Product deleted successfully", status: :ok}
        else
          render json: { errors: "Product not deleted"}, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Record not found"}, status: :not_found
      end


      private

      def product_params
        params.require(:product).permit(
          :name,
          :description,
          :sku,
          :price,
          :discount_price,
          :status,
          :brand,
          :weight,
          :category_id
        )
      end
    end
  end
end
