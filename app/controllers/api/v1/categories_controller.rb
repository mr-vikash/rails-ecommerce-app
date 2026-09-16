class Api::V1::CategoriesController < ApplicationController
  include Authentication
  def index
    @categories = Category.all
  end

  def show
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {error: "Category not found"}, status: :unprocessable_entity
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render :show, status: :created
    else
      render json: { errors: @category.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      render :show, status: :ok
    else
      render json: { errors: @product.errors.full_messages}
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Category not Found"}, status: :unprocessable_entity
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      render :show, status: :ok
    else
      render json: { error: "Category not deleted"}, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Category not Found"}, status: :unprocessable_entity
  end


  private

  def category_params
     params.require(:category).permit(
      :name,
      :description,
      :slug,
      :parent_id,
      :status
    )
  end
end
