module Admin
  class PurchaseOrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_purchase_order

    def index
      @purchase_orders = PurchaseOrder.includes(:customer, :supplier).order(created_at: :desc)
    end

    def show
      @items = @purchase_order.purchase_order_items.includes(:product)
    end

    def confirmar
      @purchase_order.update!(status: "confirmada")
      @purchase_order.quotation.update!(status: "concluida") if @purchase_order.quotation.present?
      redirect_to admin_purchase_order_path(@purchase_order), notice: "Pedido confirmado com sucesso."
    end

    def arquivar
      @purchase_order.update!(status: "arquivada")
      @purchase_order.quotation.update!(status: "arquivada") if @purchase_order.quotation.present?
      redirect_to admin_purchase_order_path(@purchase_order), notice: "Pedido arquivado com sucesso."
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
