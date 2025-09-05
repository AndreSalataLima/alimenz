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
      if params[:user][:category_ids]
        @supplier.category_ids = params[:user][:category_ids].reject(&:blank?)
      end

      if params[:user][:service_city_ids]
        @supplier.supplier_served_cities.destroy_all
        params[:user][:service_city_ids].reject(&:blank?).each do |city_id|
          @supplier.supplier_served_cities.find_or_create_by!(city_id: city_id)
        end
      end

      if @supplier.update(supplier_params.except(:category_ids, :service_city_ids))
        redirect_to admin_supplier_path(@supplier), notice: "Fornecedor atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity, formats: [:html]
      end
    end

    private

    def set_supplier
      @supplier = User.find(params[:id])
    end

    def supplier_params
      params.require(:user).permit(
        :name, :email, :cnpj, :responsible, :address, :logo, :phone, :trade_name,
        signature_attributes: [ :id, :signature_image, :stamp_image, :_destroy ],
        category_ids: []
      )
    end

    def verify_admin
      redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"
    end
  end
end
