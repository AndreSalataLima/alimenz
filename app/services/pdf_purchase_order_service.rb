# app/services/pdf_purchase_order_service.rb
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
    # if @purchase_order.quotation&.title.present?
    #   pdf.move_down 5
    #   pdf.text @purchase_order.quotation.title, size: 14, style: :italic, align: :center
    # end

    pdf.move_down 10
    pdf.text "Data de Emissão: #{Date.today.strftime('%d/%m/%Y')}", align: :center, size: 10
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    customer = @purchase_order.customer
    supplier = @purchase_order.supplier

    # Blocos lado a lado com alinhamento vertical
    y_position = pdf.cursor

    pdf.bounding_box([0, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Cliente:", style: :bold
      pdf.text "Nome: #{customer.name}"
      pdf.text "Nome Fantasia: #{customer.trade_name}" if customer.trade_name.present?
      pdf.text "CNPJ: #{customer.cnpj}"
      pdf.text "Endereço: #{customer.address}"
      pdf.text "Telefone: #{customer.phone}"
    end

    pdf.bounding_box([pdf.bounds.width / 2 + 10, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Fornecedor:", style: :bold
      pdf.text "Nome: #{supplier.name}"
      pdf.text "Nome Fantasia: #{supplier.trade_name}" if supplier.trade_name.present?
      pdf.text "CNPJ: #{supplier.cnpj}"
      pdf.text "Endereço: #{supplier.address}"
      pdf.text "Telefone: #{supplier.phone}"
      pdf.text "Responsável: #{supplier.responsible}"
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    if @purchase_order.quotation&.general_comment.present?
      pdf.text "Observações gerais da cotação:", style: :bold
      pdf.text @purchase_order.quotation.general_comment
      pdf.move_down 10
    end

    # Tabela de Itens
    table_data = [[
      "<b>ITEM</b>",
      "<b>DESCRIÇÃO</b>",
      "<b>QUANT</b>",
      "<b>UNID</b>",
      "<b>PREÇO UNI (R$)</b>",
      "<b>TOTAL (R$)</b>"
    ]]
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
        table.column(4).width = 60
        table.column(5).width = 60
      end
    else
      pdf.text "Nenhum item no pedido de compra.", align: :center
    end

    pdf.move_down 40
    pdf.stroke_horizontal_rule
    pdf.move_down 30

    pdf.render
  end
end
