# app/services/pdf_purchase_order_service.rb
require "prawn"
require "prawn/table"

class PdfPurchaseOrderService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Título com título da cotação (se houver)
    title = @purchase_order.quotation&.title
    if title.present?
      pdf.text title, size: 20, style: :bold, align: :center
      pdf.move_down 5
      pdf.text "Pedido de Compra ##{@purchase_order.id}", size: 14, style: :italic, align: :center
    else
      pdf.text "Pedido de Compra ##{@purchase_order.id}", size: 20, style: :bold, align: :center
    end

    pdf.move_down 20

    supplier = @purchase_order.supplier
    customer = @purchase_order.customer

    # Dados do fornecedor
    pdf.text "Fornecedor:", style: :bold
    pdf.text "Nome: #{supplier.name}"
    pdf.text "Nome Fantasia: #{supplier.trade_name}" if supplier.trade_name.present?
    pdf.text "CNPJ: #{supplier.cnpj}"
    pdf.text "Endereço: #{supplier.address}"
    pdf.text "Telefone: #{supplier.phone}"
    pdf.text "Responsável: #{supplier.responsible}"
    pdf.move_down 10

    # Dados do cliente
    pdf.text "Cliente:", style: :bold
    pdf.text "Nome: #{customer.name}"
    pdf.text "Nome Fantasia: #{customer.trade_name}" if customer.trade_name.present?
    pdf.text "CNPJ: #{customer.cnpj}"
    pdf.text "Endereço: #{customer.address}"
    pdf.text "Telefone: #{customer.phone}"
    pdf.move_down 20

    # Tabela de produtos: ITEM, DESCRIÇÃO, UNID, QUANTIDADE
    data = [["ITEM", "DESCRIÇÃO", "UNID", "QUANTIDADE"]]
    @purchase_order.purchase_order_items.each_with_index do |item, index|
      product = item.product
      customized = customer.customized_products.find_by(product_id: product.id)
      description = customized&.custom_name.presence || product.generic_name

      data << [
        index + 1,
        description,
        item.unit,
        item.quantity
      ]
    end

    if data.size > 1
      pdf.table(data, header: true, cell_style: { borders: [:bottom], padding: 5 }) do |t|
        t.row(0).background_color = "DDDDDD"
        t.row(0).font_style = :bold
      end
    else
      pdf.text "Nenhum item no pedido de compra."
    end

    pdf.move_down 40
    pdf.stroke_horizontal_rule
    pdf.move_down 30

    # Rodapé: Assinatura
    pdf.text "Assinatura: ______________________________", align: :left
    pdf.text "Responsável: #{supplier.responsible}", align: :left

    pdf.render
  end
end
