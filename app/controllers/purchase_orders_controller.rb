class PurchaseOrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.role == "supplier"
      @purchase_orders = PurchaseOrder.where(supplier_id: current_user.id).order(created_at: :desc)
    else
      @purchase_orders = PurchaseOrder.where(customer_id: current_user.id).order(created_at: :desc)
    end
  end


  def show
    @purchase_order = PurchaseOrder.find(params[:id])

    unless @purchase_order.customer == current_user || @purchase_order.supplier == current_user
      redirect_to purchase_orders_path, alert: "Access denied."
    end
  end

  def new
    @purchase_orders = current_user.purchase_orders.build
    @suppliers = current_user.quotation_responses.where(status: "finalizado").map(&:supplier).uniq
  end

  def create
    @purchase_orders = current_user.purchase_orders.build(purchase_order_params)
    if @purchase_orders.save
      redirect_to @purchase_orders, notice: "Purchase order generated successfully."
    else
      @suppliers = current_user.quotation_responses.where(status: "finalizado").map(&:supplier).uniq
      render :new, status: :unprocessable_entity
    end
  end

  def pdf
    @purchase_orders = PurchaseOrder.includes(:purchase_order_items).find(params[:id])
    pdf = PdfPurchaseOrderService.new(@purchase_orders).generate

    send_data pdf,
              filename: "purchase_order_#{@purchase_orders.id}.pdf",
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
