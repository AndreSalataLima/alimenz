class PurchaseOrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.role == "supplier"
      @orders = PurchaseOrder.where(supplier_id: current_user.id).order(created_at: :desc)
    else
      @orders = PurchaseOrder.where(customer_id: current_user.id).order(created_at: :desc)
    end
  end

  def show
    @order = PurchaseOrder.find(params[:id])
    redirect_to purchase_orders_path, alert: "Access denied." unless @order.customer == current_user
  end

  def new
    @order = current_user.purchase_orders.build
    @suppliers = current_user.quotation_responses.where(status: "finalizado").map(&:supplier).uniq
  end

  def create
    @order = current_user.purchase_orders.build(purchase_order_params)
    if @order.save
      redirect_to @order, notice: "Purchase order generated successfully."
    else
      @suppliers = current_user.quotation_responses.where(status: "finalizado").map(&:supplier).uniq
      render :new, status: :unprocessable_entity
    end
  end

  def pdf
    @order = PurchaseOrder.includes(:purchase_order_items).find(params[:id])
    pdf = PdfPurchaseOrderService.new(@order).generate

    send_data pdf,
              filename: "purchase_order_#{@order.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def purchase_order_params
    params.require(:purchase_order).permit(
      :supplier_id, :total_value, :expiration_date, :status,
      purchase_order_items_attributes: [ :product_id, :quantity, :unit, :price, :_destroy ]
    )
  end
end
