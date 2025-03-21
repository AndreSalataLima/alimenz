class CustomizedProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_customer

  def create
    @product = Product.find(params[:product_id])
    custom = CustomizedProduct.find_or_initialize_by(customer_id: current_user.id, product_id: @product.id)
    custom.custom_name = params[:custom_name]

    if custom.save
      head :ok
    else
      render json: { error: "Erro ao salvar nome personalizado" }, status: :unprocessable_entity
    end
  end

  private

  def verify_customer
    redirect_to root_path unless current_user&.role == "customer"
  end
end
