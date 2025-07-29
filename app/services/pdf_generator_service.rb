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
    pdf.text "Data de Emissão: #{Date.today.strftime('%d/%m/%Y')}  |  Válido até: #{@response.expiration_date.strftime('%d/%m/%Y')}", align: :center, size: 10
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    quotation = @response.quotation
    customer_data = quotation.customer_snapshot.symbolize_keys
    supplier_data = @response.supplier_snapshot.present? ? @response.supplier_snapshot.symbolize_keys : @response.supplier.attributes.symbolize_keys


    # Blocos lado a lado com alinhamento vertical
    y_position = pdf.cursor

    pdf.bounding_box([0, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Entidade Participante:", style: :bold
      pdf.text "Nome: #{customer_data[:name]}"
      pdf.text "Nome Fantasia: #{customer_data[:trade_name]}" if customer_data[:trade_name].present?
      pdf.text "CNPJ: #{customer_data[:cnpj]}"
      pdf.text "Endereço: #{customer_data[:address]}"
      pdf.text "Telefone: #{customer_data[:phone]}"

    end

    pdf.bounding_box([pdf.bounds.width / 2 + 10, y_position], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Empresa Proponente:", style: :bold
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

    # Tabela de Cotação de Preços
    table_data = [["ITEM", "DESCRIÇÃO", "QUANT", "UNID", "PREÇO UNI (R$)", "TOTAL (R$)"]]
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
        description,
        quantity,
        unit,
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

    if @use_signature && @response.signed_at.present?
      pdf.move_down 40
      pdf.text "Assinado digitalmente por #{@response.supplier.responsible}",
              size: 10, align: :center
      pdf.text "Data: #{@response.signed_at.strftime('%d/%m/%Y %H:%M')} – IP: #{@response.signed_ip}", size: 10, align: :center
      pdf.text "Código de rastreio: #{@response.signature_tracking_id}", size: 10, align: :center
    else
      pdf.move_down 60
      pdf.text "_______________________________", align: :center
      pdf.text @response.supplier.responsible, align: :center, size: 10
    end

    pdf.render
  end

  def filename
    title = @response.quotation.title.presence
    if title.present?
      "cotacao_#{parameterize_title(title)}.pdf"
    else
      customer = @response.quotation.customer.name.parameterize(separator: '_')
      supplier = @response.supplier.name.parameterize(separator: '_')
      date = I18n.l(@response.created_at.to_date, format: "%d.%m")
      "cotacao_#{customer}_#{supplier}_#{date}.pdf"
    end
  end


  private

  def parameterize_title(title)
    title.downcase.strip.gsub(/[^a-z0-9\s]/i, '').gsub(/[\s_]+/, '_')
  end

end
