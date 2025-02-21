require "prawn"
require "prawn/table"

class PdfGeneratorService
  def initialize(resposta)
    @resposta = resposta
  end

  def generate
    Prawn::Document.new do |pdf|
      pdf.text "Resposta de Cotação ##{@resposta.id}", size: 20, style: :bold
      pdf.text "Fornecedor: #{@resposta.fornecedor.nome}"
      pdf.text "Cliente: #{@resposta.cotacao.cliente.nome}"
      pdf.text "Data de Validade: #{@resposta.data_validade.strftime('%d/%m/%Y')}"
      pdf.move_down 10

      # Cria a tabela apenas com itens disponíveis e com preço diferente de 0
      data = [["Produto", "Quantidade", "Unidade", "Preço (R$)"]]
      @resposta.resposta_de_cotacao_items.includes(:item_de_cotacao).each do |item|
        # Ignora itens indisponíveis ou cujo preço é 0
        next unless item.disponivel

        produto = item.item_de_cotacao.produto
        data << [
          produto.nome_generico,
          item.item_de_cotacao.quantidade,
          item.item_de_cotacao.unidade_selecionada,
          "R$ #{'%.2f' % item.preco}"
        ]
      end

      if data.size > 1
        pdf.table(data, header: true, cell_style: { borders: [:bottom], padding: 5 })
      else
        pdf.text "Nenhum item disponível para cotação."
      end

      pdf.move_down 20
      pdf.text "_________________________", align: :center
      pdf.text "Assinatura do Fornecedor", align: :center
    end.render
  end
end
