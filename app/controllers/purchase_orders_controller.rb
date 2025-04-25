class PurchaseOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_and_authorize_purchase_order, only: [:show, :pdf]

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
    pdf = PdfPurchaseOrderService.new(@purchase_order).generate

    send_data pdf,
              filename: PdfPurchaseOrderService.new(@purchase_order).filename,
              type: "application/pdf",
              disposition: "inline"
  end

  def secure_pdf
    @purchase_order = PurchaseOrder.find_signed!(params[:signed_id])
    authorize @purchase_order
    service = PdfPurchaseOrderService.new(@purchase_order)
    pdf = service.generate

    send_data pdf,
              filename: PdfPurchaseOrderService.new(@purchase_order).filename,
              type: "application/pdf",
              disposition: "inline"
  end


  private

  def set_and_authorize_purchase_order
    @purchase_order = policy_scope(PurchaseOrder).find_by(id: params[:id])

    if @purchase_order.nil?
      redirect_to purchase_orders_path, alert: "Pedido de compra não encontrado ou acesso não autorizado."
    else
      authorize @purchase_order
    end
  end


  def purchase_order_params
    params.require(:purchase_order).permit(
      :supplier_id, :total_value, :expiration_date, :status,
      purchase_order_items_attributes: [ :product_id, :quantity, :unit, :price, :_destroy ]
    )
  end
end
