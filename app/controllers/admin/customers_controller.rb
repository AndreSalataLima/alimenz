module Admin
  class CustomersController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_customer, only: [:show, :edit, :update]

    def index
      @customers = User.where(role: "customer")
    end

    def show
      # Displays customer details, including signature (if available)
    end

    def edit
      # Displays form to edit customer data and upload signature
    end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "Customer updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_customer
      @customer = User.find(params[:id])
    end

    def customer_params
      params.require(:user).permit(:phone, signature_attributes: [:signature_image, :stamp_image, :_destroy])
    end

    def verify_admin
      redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"
    end
  end
end
