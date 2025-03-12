class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin, except: [:index, :show]

  def index
    @products = Product.order(:generic_name)
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: "Product created successfully."
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to @product, notice: "Product updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: "Product removed successfully."
  end

  private

  def product_params
    params.require(:product).permit(:category_id, :subcategory_id, :brand, :unit_options, :generic_name)
  end

  def verify_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.role == "admin"
  end
end
