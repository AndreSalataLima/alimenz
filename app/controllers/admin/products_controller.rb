module Admin
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    def index
      @products = Product.all
    end

    def show; end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_product_path(@product), notice: "Produto criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Produto atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Produto removido com sucesso."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      data = params.require(:product).permit(:generic_name, :brand, :unit_options)
      data[:unit_options] = data[:unit_options].split(",").map(&:strip) if data[:unit_options].is_a?(String)
      data
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user&.role == "admin"
    end
  end
end
