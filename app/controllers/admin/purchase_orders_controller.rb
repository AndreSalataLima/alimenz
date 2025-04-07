module Admin
  class PurchaseOrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_purchase_order, only: [:show]

    def index
      @purchase_orders = PurchaseOrder.includes(:customer, :supplier).order(created_at: :desc)
    end

    def show
      @items = @purchase_order.purchase_order_items.includes(:product)
    end

    private

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user.role == "admin"
    end
  end
end
