require "prawn"
require "prawn/table"

class PdfPurchaseOrderService
  def initialize(purchase_order)
    @purchase_order = purchase_order
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho
    pdf.text "Pedido de Compra ##{@purchase_order.id}", size: 20, style: :bold
    pdf.text "Fornecedor: #{@purchase_order.supplier.name}"
    pdf.text "Cliente: #{@purchase_order.customer.name}"
    if @purchase_order.expiration_date
      pdf.text "Data de Validade: #{@purchase_order.expiration_date.strftime('%d/%m/%Y')}"
    end
    pdf.move_down 10

    # Tabela de Itens do Pedido
    data = [ [ "Produto", "Quantidade", "Unidade", "Preço Unitário (R$)", "Total (R$)" ] ]
    @purchase_order.purchase_order_items.each do |item|
      product = item.product
      quantity = item.quantity.to_f
      unit_price = item.price.to_f
      customer = @purchase_order.customer
      customized = customer.customized_products.find_by(product_id: product.id)
      product_name = customized&.custom_name.presence || product.generic_name
      total_item = quantity * unit_price

      data << [
        product_name,
        quantity,
        item.unit,
        "R$ #{'%.2f' % unit_price}",
        "R$ #{'%.2f' % total_item}"
      ]

    end

    if data.size > 1
      pdf.table(data, header: true, cell_style: { borders: [ :bottom ], padding: 5 })
    else
      pdf.text "Nenhum item no pedido de compra."
    end

    pdf.move_down 20
    pdf.text "Valor Total do Pedido: R$ #{'%.2f' % @purchase_order.total_value}", size: 16, style: :bold, align: :right

    pdf.render
  end
end
