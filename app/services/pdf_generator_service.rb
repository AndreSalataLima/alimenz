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

    # Cabeçalho – Informações da Proposta de Cotação
    pdf.text "PROPOSTA DE COTAÇÃO", size: 20, style: :bold, align: :center
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    # Dados da Entidade Participante – dados do cliente que criou a cotação
    customer = @response.quotation.customer
    customer_name = customer.name
    customer_cnpj = customer.cnpj

    # Dados da Empresa Proponente – dados do fornecedor que respondeu à cotação
    supplier = @response.supplier
    supplier_name      = supplier.name
    supplier_cnpj      = supplier.cnpj
    supplier_address   = supplier.address
    supplier_phone     = supplier.phone
    supplier_responsible   = supplier.responsible
    issue_date         = Date.today.strftime("%d/%m/%Y")
    validity           = @response.quotation.expiration_date.strftime("%d/%m/%Y")

    # Exibe os dados em duas colunas
    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Entidade Participante:", style: :bold
      pdf.text customer_name
      pdf.text "CNPJ: #{customer_cnpj}"
    end

    pdf.bounding_box([ pdf.bounds.width / 2 + 10, pdf.cursor + 40 ], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Empresa Proponente:", style: :bold
      pdf.text supplier_name
      pdf.text "CNPJ: #{supplier_cnpj}"
      pdf.text "Endereço: #{supplier_address}"
      pdf.text "Telefone: #{supplier_phone}"
      pdf.text "Data de emissão: #{issue_date}"
      pdf.text "Validade: #{validity}"
      pdf.text "Responsável: #{supplier_responsible}"
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Tabela de Cotação de Preços
    table_data = [ [ "ITEM", "QUANT", "UNID", "DESCRIÇÃO", "PREÇO UNI (R$)", "TOTAL (R$)" ] ]
    item_index = 1
    @response.quotation_response_items.includes(:quotation_item).each do |item|
      next unless item.available

      quotation_item = item.quotation_item
      product    = quotation_item.product
      quantity   = quotation_item.quantity
      unit       = quotation_item.selected_unit
      description = product.generic_name
      unit_price = item.price
      total      = quantity * unit_price

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

    pdf.move_down 30
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Rodapé – Assinatura, Carimbo e Dados da Empresa
    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
      pdf.text "Assinatura:", style: :bold, align: :left

      if @use_signature && supplier.signature&.signature_image&.attached?
        file = supplier.signature.signature_image.download
        signature_image = StringIO.open(file)
        pdf.bounding_box([ 150, pdf.cursor + 15 ], width: 150, height: 50) do
          pdf.image signature_image, fit: [ 150, 50 ]
        end
      end
    end

    pdf.move_down 30

    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
      pdf.text "Carimbo da empresa:", style: :bold, align: :left

      if supplier.signature&.stamp_image&.attached?
        file = supplier.signature.stamp_image.download
        stamp_image = StringIO.open(file)
        pdf.bounding_box([ 200, pdf.cursor + 15 ], width: 150, height: 50) do
          pdf.image stamp_image, fit: [ 150, 50 ]
        end
      end
    end

    pdf.move_down 20
    pdf.text "Dados da Empresa:", style: :bold
    pdf.text "Razão Social: #{supplier_name}"
    pdf.text "CNPJ: #{supplier_cnpj}"
    pdf.text "Endereço: #{supplier_address}"
    pdf.text "Telefone: #{supplier_phone}"

    pdf.render
  end
end
