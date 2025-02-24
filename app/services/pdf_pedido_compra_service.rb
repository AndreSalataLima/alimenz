require "prawn"
require "prawn/table"

class PdfPedidoCompraService
  def initialize(pedido)
    @pedido = pedido
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho
    pdf.text "Pedido de Compra ##{@pedido.id}", size: 20, style: :bold
    pdf.text "Fornecedor: #{@pedido.fornecedor.nome}"
    pdf.text "Cliente: #{@pedido.cliente.nome}"
    if @pedido.data_validade
      pdf.text "Data de Validade: #{@pedido.data_validade.strftime('%d/%m/%Y')}"
    end
    pdf.move_down 10

    # Tabela de Itens do Pedido
    data = [["Produto", "Quantidade", "Unidade", "Preço Unitário (R$)", "Total (R$)"]]
    @pedido.itens.each do |item|
      # Cada item é um hash com chaves: "produto_id", "quantidade", "preco", "unidade"
      produto = Produto.find(item["produto_id"])
      quantidade = item["quantidade"].to_f
      preco_unitario = item["preco"].to_f
      total_item = quantidade * preco_unitario

      data << [
        produto.nome_generico,
        quantidade,
        item["unidade"],
        "R$ #{'%.2f' % preco_unitario}",
        "R$ #{'%.2f' % total_item}"
      ]
    end

    if data.size > 1
      pdf.table(data, header: true, cell_style: { borders: [:bottom], padding: 5 })
    else
      pdf.text "Nenhum item no pedido de compra."
    end

    pdf.move_down 20
    pdf.text "Valor Total do Pedido: R$ #{'%.2f' % @pedido.valor_total}", size: 16, style: :bold, align: :right

    pdf.render
  end
end
