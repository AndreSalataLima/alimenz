require "prawn"
require "prawn/table"
require "stringio"

class PdfGeneratorService
  def initialize(response, use_signature: false)
    @response = response
    @use_signature = use_signature
  end

  def generate
    @response.reload
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho da Proposta
    pdf.text "PROPOSTA DE COTAÇÃO", size: 20, style: :bold, align: :center

    if @response.quotation.title.present?
      pdf.move_down 5
      pdf.text @response.quotation.title, size: 14, style: :italic, align: :center
    end

    pdf.move_down 10
    pdf.text "Data de Emissão: #{Date.today.strftime('%d/%m/%Y')}  |  Data limite de conclusão de compra: #{@response.quotation.expiration_date.strftime('%d/%m/%Y')}", align: :center, size: 10
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    customer = @response.quotation.customer
    supplier = @response.supplier

    # Blocos lado a lado com alinhamento vertical
    y_position = pdf.cursor

    pdf.bounding_box([0, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Entidade Participante:", style: :bold
      pdf.text "Nome: #{customer.name}"
      pdf.text "Nome Fantasia: #{customer.trade_name}" if customer.trade_name.present?
      pdf.text "CNPJ: #{customer.cnpj}"
      pdf.text "Endereço: #{customer.address}"
      pdf.text "Telefone: #{customer.phone}"
    end

    pdf.bounding_box([pdf.bounds.width / 2 + 10, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Empresa Proponente:", style: :bold
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

    # Tabela de Cotacão de Preços
    table_data = [["ITEM", "QUANT", "UNID", "DESCRIÇÃO", "PREÇO UNI (R$)", "TOTAL (R$)"]]
    item_index = 1

    @response.quotation_response_items.includes(:quotation_item).each do |item|
      next unless item.available

      quotation_item = item.quotation_item
      product = quotation_item.product
      quantity = quotation_item.quantity
      unit = quotation_item.selected_unit
      customized = @response.quotation.customer.customized_products.find_by(product_id: product.id)
      description = customized&.custom_name.presence || product.generic_name
      unit_price = item.price
      total = quantity * unit_price

      table_data << [
        item_index,
        quantity,
        unit,
        description,
        "R$ #{'%.2f' % unit_price}",
        "R$ #{'%.2f' % total}"
      ]
      item_index += 1
    end

    if table_data.size > 1
      pdf.table(table_data, header: true, width: pdf.bounds.width) do |table|
        table.row(0).background_color = "DDDDDD"
        table.row(0).font_style = :bold
        table.columns(4..5).align = :right
        table.column(0).align = :center
      end
    else
      pdf.text "Nenhum item disponível para cotação.", align: :center
    end

    pdf.move_down 60
    pdf.text "_______________________________", align: :center
    pdf.text supplier.responsible, align: :center, size: 10

    pdf.render
  end
end
