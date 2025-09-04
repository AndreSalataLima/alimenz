require "prawn"
require "prawn/table"

class PdfPurchaseOrderService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def generate
    @purchase_order.reload
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho
    pdf.text "PEDIDO DE COMPRA", size: 20, style: :bold, align: :center
    pdf.move_down 10
    pdf.text "Data de Emissão: #{Date.today.strftime('%d/%m/%Y')}", align: :center, size: 10
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    quotation = @purchase_order.quotation
    customer_data = quotation.customer_snapshot.symbolize_keys
    customer = @purchase_order.customer
    response = quotation.quotation_responses.find_by(supplier_id: @purchase_order.supplier_id, status: "concluida")
    supplier_data = response&.supplier_snapshot&.symbolize_keys || @purchase_order.supplier.attributes.symbolize_keys


    # Dados do Cliente e Fornecedor
    y_position = pdf.cursor
    pdf.bounding_box([ 0, y_position ], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Cliente:", style: :bold
      pdf.text "Nome: #{customer_data[:name]}"
      pdf.text "Nome Fantasia: #{customer_data[:trade_name]}" if customer_data[:trade_name].present?
      pdf.text "CNPJ: #{customer_data[:cnpj]}"
      pdf.text "Endereço: #{customer_data[:address]}"
      pdf.text "Telefone: #{customer_data[:phone]}"
    end

    pdf.bounding_box([ pdf.bounds.width / 2 + 10, y_position ], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Fornecedor:", style: :bold
      pdf.text "Nome: #{supplier_data[:name]}"
      pdf.text "Nome Fantasia: #{supplier_data[:trade_name]}" if supplier_data[:trade_name].present?
      pdf.text "CNPJ: #{supplier_data[:cnpj]}"
      pdf.text "Endereço: #{supplier_data[:address]}"
      pdf.text "Telefone: #{supplier_data[:phone]}"
      pdf.text "Responsável: #{supplier_data[:responsible]}"
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Comentário geral da cotação
    if @purchase_order.general_comment.present?
      pdf.text "Observações gerais do pedido:", style: :bold
      pdf.text @purchase_order.general_comment
      pdf.move_down 10
    end

    # Tabela de itens
    table_data = [ [
      "<b>ITEM</b>",
      "<b>DESCRIÇÃO</b>",
      "<b>QUANT</b>",
      "<b>UNID</b>",
      "<b>PREÇO UNI (R$)</b>",
      "<b>TOTAL (R$)</b>"
    ] ]
    item_index = 1

    @purchase_order.purchase_order_items.each do |item|
      product = item.product
      customized = customer.customized_products.find_by(product_id: product.id)
      description = customized&.custom_name.presence || product.generic_name

      quotation_item = @purchase_order.quotation.quotation_items.find_by(product_id: product.id)
      comment = quotation_item&.product_comment
      description += "\nObs: #{comment}" if comment.present?

      quantity = item.quantity
      unit = item.unit
      unit_price = item.price
      total = quantity * unit_price

      table_data << [
        item_index,
        description,
        quantity,
        unit,
        "R$ #{'%.2f' % unit_price}",
        "R$ #{'%.2f' % total}"
      ]
      item_index += 1
    end

    if table_data.size > 1
      pdf.table(table_data, header: true, width: pdf.bounds.width, cell_style: { inline_format: true }) do |table|
        table.row(0).background_color = "DDDDDD"
        table.row(0).align = :center
        table.column(0).width = 40
        table.column(2).width = 60
        table.column(3).width = 60
        table.column(4).width = 80
        table.column(5).width = 80
      end
    else
      pdf.text "Nenhum item no pedido de compra.", align: :center
    end

    pdf.move_down 40
    pdf.stroke_horizontal_rule
    pdf.move_down 30

    pdf.number_pages "<page>/<total>",
                 at: [ pdf.bounds.right - 50, 0 ],
                 width: 50,
                 align: :right,
                 size: 9,
                 start_count_at: 1

    pdf.render
  end

  def filename
    title = @purchase_order.quotation&.title.presence
    if title.present?
      "solic_de_compra_#{parameterize_title(title)}.pdf"
    else
      customer = @purchase_order.customer.name.parameterize(separator: "_")
      supplier = @purchase_order.supplier.name.parameterize(separator: "_")
      date = I18n.l(@purchase_order.created_at.to_date, format: "%d.%m")
      "solic_de_compra_#{customer}_#{supplier}_#{date}.pdf"
    end
  end

  private

  def parameterize_title(title)
    title.downcase.strip.gsub(/[^a-z0-9\s]/i, "").gsub(/[\s_]+/, "_")
  end
end
