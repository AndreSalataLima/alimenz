class QuotationsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_customer, only: [:new, :create, :select_orders, :orders_summary, :finalize_orders]

  def preview_pdf_data
    @quotation = Quotation.find(params[:id])
    # Assume the desired response is the first with status "finalizado"
    @quotation_response = @quotation.quotation_responses.find_by(status: "finalizado")
    unless @quotation_response
      redirect_to @quotation, alert: "No finalizado response found for this quotation."
    end
  end

  def index
    @quotations = current_user.quotations.order(created_at: :desc)
    @quotations = @quotations.where(status: params[:status]) if params[:status].present?
  end

  def new
    @quotation = Quotation.new
    @quotation.quotation_items.build
    @products = Product.all
  end

  def show
    @quotation = Quotation.find(params[:id])
  end

  def create
    @quotation = current_user.quotations.build(quotation_params)
    if @quotation.save
      redirect_to @quotation, notice: "Quotation created successfully."
    else
      redirect_to customer_home_path, alert: @quotation.errors.full_messages.join(", ")
    end
  end

  # Step 4: Display table for selecting items with suppliers
  def select_orders
    @quotation = Quotation.find(params[:id])
    @items = @quotation.quotation_items.includes(:product)
    supplier_ids = @quotation.quotation_responses.where(status: "finalizado").pluck(:supplier_id).uniq
    @suppliers = User.where(id: supplier_ids)
  end

  # Step 5: Process selection and display grouped summary by supplier
  def orders_summary
    @quotation = Quotation.find(params[:id])
    selected = params[:selected] || {}

    @selected_responses = QuotationResponse.where(id: selected.keys)
    @responses_by_supplier = @selected_responses.group_by(&:supplier_id)

    @items_by_response = {}
    @selected_responses.each do |response|
      selected_item_ids = selected[response.id.to_s]&.keys || []
      filtered_items = response.quotation_response_items.select do |r_item|
        selected_item_ids.include?(r_item.quotation_item.id.to_s)
      end
      @items_by_response[response.id] = filtered_items
    end

    @summaries = {}
    @selected_responses.each do |response|
      total = @items_by_response[response.id].sum do |item|
        item.price.to_f * item.quotation_item.quantity.to_f
      end
      @summaries[response.supplier_id] ||= 0
      @summaries[response.supplier_id] += total
    end
  end

  # Step 7: Finalize and generate purchase orders for confirmed suppliers
  def finalize_orders
    @quotation = Quotation.find(params[:id])
    selected = params[:selected] || {}
    selected_responses = QuotationResponse.where(id: selected.keys)

    items_by_response = {}
    selected_responses.each do |response|
      selected_item_ids = selected[response.id.to_s]&.keys || []
      filtered_items = response.quotation_response_items.select do |r_item|
        selected_item_ids.include?(r_item.quotation_item.id.to_s)
      end
      items_by_response[response.id] = filtered_items
    end

    responses_by_supplier = selected_responses.group_by(&:supplier_id)
    @created_orders = []

    confirmations = params[:confirmations] || {}

    responses_by_supplier.each do |supplier_id, responses|
      next unless confirmations[supplier_id.to_s] == "1"

      items = []
      responses.each do |response|
        items.concat(items_by_response[response.id])
      end

      total_value = items.sum { |item| item.price.to_f * item.quotation_item.quantity.to_f }

      order = current_user.purchase_orders.create!(
        supplier_id: supplier_id,
        total_value: total_value,
        expiration_date: @quotation.expiration_date,
        status: "pendente"
      )

      items.each do |i|
        PurchaseOrderItem.create!(
          purchase_order_id: order.id,
          product_id: i.quotation_item.product_id,
          quantity: i.quotation_item.quantity,
          price: i.price,
          unit: i.quotation_item.selected_unit
        )
      end

      @created_orders << order
    end

    redirect_to purchase_orders_path, notice: "Purchase orders generated successfully."
  end

  private

  def quotation_params
    params.require(:quotation).permit(:expiration_date,
      quotation_items_attributes: [:product_id, :quantity, :selected_unit, :keep_generic_name]
    )
  end

  def verify_customer
    redirect_to root_path, alert: "Access denied." unless current_user.role == "customer"
  end
end
