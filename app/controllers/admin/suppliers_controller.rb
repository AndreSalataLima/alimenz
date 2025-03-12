module Admin
  class SuppliersController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_supplier, only: [ :show, :edit, :update ]

    def index
      @suppliers = User.where(role: "supplier")
    end

    def show
      # Displays supplier details, including signature (if available)
    end

    def edit
      # Displays form to edit supplier data and upload signature
    end

    def update
      if @supplier.update(supplier_params)
        redirect_to admin_supplier_path(@supplier), notice: "Supplier updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_supplier
      @supplier = User.find(params[:id])
    end

    def supplier_params
      params.require(:user).permit(:phone, signature_attributes: [ :id, :signature_image, :stamp_image, :_destroy ])
    end

    def verify_admin
      redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"
    end
  end
end
