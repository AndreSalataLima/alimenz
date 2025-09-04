class QuotationsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_customer, only: [ :new, :create, :select_orders, :orders_summary, :finalize_orders ]

  # def preview_pdf_data
  #   @quotation = Quotation.find(params[:id])
  #   @quotation_response = @quotation.quotation_responses.find_by(status: "finalizado")
  #   unless @quotation_response
  #     redirect_to @quotation, alert: "No finalizado response found for this quotation."
  #   end
  # end

  def index
    @quotations = current_user.quotations.order(created_at: :desc)
    @quotations = @quotations.where(status: params[:status]) if params[:status].present?
  end

  def new
    @quotation = Quotation.new
    @quotation.quotation_items.build
    @categories = Category.order(:name)

    @selected_category = params[:category_id]
    @search_term = params[:search]

    products = Product.all
    products = products.where(category_id: @selected_category) if @selected_category.present?
    products = products.where("generic_name ILIKE ?", "%#{@search_term}%") if @search_term.present?

    @pagy, @products = pagy(products.order(:generic_name), items: 15)

    respond_to do |format|
      format.html
      format.turbo_stream {
        render partial: "quotations/product_list", locals: { f: nil }
      }
    end
  end

  def show
    @quotation = Quotation.find(params[:id])
  end

  def create
    puts params[:quotation][:quotation_items_attributes].inspect

    @quotation = current_user.quotations.build(quotation_params)

    if @quotation.save
      if params[:customized_products].present?
        params[:customized_products].each do |product_id, custom_name|
          next if custom_name.blank?

          customized = CustomizedProduct.find_or_initialize_by(
            customer: current_user,
            product_id: product_id
          )
          customized.custom_name = custom_name
          customized.save
        end
      end

      redirect_to @quotation, notice: "Cotação criada com sucesso."
    else
      redirect_to customer_home_path, alert: @quotation.errors.full_messages.join(", ")
    end
  end

  # Step 4: Display table for selecting items with suppliers
  def select_orders
    @quotation = Quotation.find(params[:id])
    @items = @quotation.quotation_items.includes(:product)

    approved_responses_scope = @quotation.quotation_responses
                                        .where(status: [ "resposta_aprovada", "concluida" ])
                                        .where(analysis_status: "aprovado")
                                        .includes(:supplier, quotation_response_items: :quotation_item)

    supplier_ids = @quotation.quotation_responses
      .where(status: [ "resposta_aprovada", "concluida" ])
      .where(analysis_status: "aprovado")
      .pluck(:supplier_id)
      .uniq

    supplier_ids = approved_responses_scope.pluck(:supplier_id).uniq
    @suppliers = User.where(id: supplier_ids)

    @response_summaries = {}
    approved_responses_scope.each do |response|
      item_count = 0
      total_value = 0.0

      response.quotation_response_items.each do |response_item|
        if response_item.available && response_item.quotation_item&.quantity.to_f > 0
          item_count += 1
          total_value += response_item.price.to_f * response_item.quotation_item.quantity.to_f
        end
      end
      @response_summaries[response.id] = { item_count: item_count, total_value: total_value }
    end
  end

  # Step 5: Process selection and display grouped summary by supplier
  def orders_summary
    @quotation = Quotation.find(params[:id])

    if @quotation.status == "concluida"
      redirect_to select_orders_quotation_path(@quotation), alert: "Esta cotação já foi concluída. Não é possível avançar."
      return
    end

    selected = params[:selected] || {}
    @quantidades = params[:quantidades] || {}

    @selected_responses = QuotationResponse.where(id: selected.keys)
    @responses_by_supplier = @selected_responses.group_by(&:supplier_id)

    @items_by_response = {}
    @selected_responses.each do |response|
      selected_item_ids = selected[response.id.to_s]&.keys || []
      filtered_items = response.quotation_response_items.where(quotation_item_id: selected_item_ids)
      @items_by_response[response.id] = filtered_items
    end

    @summaries = {}
    @selected_responses.each do |response|
      total = @items_by_response[response.id].sum do |item|
        quantity = @quantidades[item.quotation_item.id.to_s]&.to_f || item.quotation_item.quantity.to_f
        item.price.to_f * quantity
      end
      @summaries[response.supplier_id] ||= 0
      @summaries[response.supplier_id] += total
    end
  end

  # Step 7: Finalize and generate purchase orders for confirmed suppliers
  def finalize_orders
    @quotation = Quotation.find(params[:id])

    if @quotation.status == "concluida"
      redirect_to select_orders_quotation_path(@quotation), alert: "Esta cotação já foi concluída. Não é possível finalizar novamente."
      return
    end

    selected = params[:selected] || {}
    quantidades = params[:quantidades] || {}
    comentarios = params[:comentarios] || {}
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

    confirmations = params[:confirmacoes] || {}

    responses_by_supplier.each do |supplier_id, responses|
      next unless confirmations[supplier_id.to_s] == "1"

      items = responses.flat_map { |r| items_by_response[r.id] }

      total_value = items.sum do |item|
        quantity = quantidades[item.quotation_item.id.to_s]&.to_f || item.quotation_item.quantity.to_f
        item.price.to_f * quantity
      end

      order = current_user.purchase_orders.create!(
        supplier_id: supplier_id,
        total_value: total_value,
        expiration_date: @quotation.expiration_date,
        quotation_id: @quotation.id,
        status: "aberta",
        general_comment: comentarios[supplier_id.to_s] || @quotation.general_comment
      )

      items.each do |i|
        quantity = quantidades[i.quotation_item.id.to_s]&.to_f || i.quotation_item.quantity.to_f

        PurchaseOrderItem.create!(
          purchase_order_id: order.id,
          product_id: i.quotation_item.product_id,
          quantity: quantity,
          price: i.price,
          unit: i.quotation_item.selected_unit
        )
      end

      @created_orders << order
    end

    # selected_responses.each do |response|
    #   response.update!(status: "concluida")
    # end

    # @quotation.update!(status: "concluida")
    redirect_to purchase_orders_path, notice: "Pedidos finalizados com sucesso."
  end

  def arquivar
    @quotation = Quotation.find(params[:id])

    if current_user == @quotation.customer
      @quotation.transaction do
        @quotation.update!(status: "arquivada")
        @quotation.quotation_responses.update_all(status: "arquivada")
        @quotation.purchase_orders.update_all(status: "arquivada")
      end

      redirect_to quotations_path, notice: "Cotação arquivada com sucesso."
    else
      redirect_to quotations_path, alert: "Você não tem permissão para arquivar esta cotação."
    end
  end



  private

  def quotation_params
    params.require(:quotation).permit(:title, :expiration_date, :response_expiration_date, :general_comment,
      quotation_items_attributes: [ :product_id, :quantity, :selected_unit, :keep_generic_name, :product_comment ]
    )
  end

  def verify_customer
    redirect_to root_path, alert: "Access denied." unless current_user.role == "customer"
  end
end
