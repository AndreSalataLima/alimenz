require "prawn"
require "prawn/table"

class PdfGeneratorService
  def initialize(resposta, usar_assinatura: false)
    @resposta = resposta
    @usar_assinatura = usar_assinatura
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho
    pdf.text "Resposta de Cotação ##{@resposta.id}", size: 20, style: :bold
    pdf.text "Fornecedor: #{@resposta.fornecedor.nome}"
    pdf.text "Cliente: #{@resposta.cotacao.cliente.nome}"
    if @resposta.data_validade
      pdf.text "Data de Validade: #{@resposta.data_validade.strftime('%d/%m/%Y')}"
    end
    pdf.move_down 10

    # Tabela de itens
    data = [["Produto", "Quantidade", "Unidade", "Preço (R$)"]]
    @resposta.resposta_de_cotacao_items.includes(:item_de_cotacao).each do |item|
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

    # Se o fornecedor optou por usar assinatura + se existe imagem
    if @usar_assinatura && @resposta.fornecedor.assinatura&.imagem_assinatura&.attached?
      file = @resposta.fornecedor.assinatura.imagem_assinatura.download
      assinatura_image = StringIO.open(file)
      ruprica_image    = StringIO.open(file)

      # Rúbrica no canto inferior direito de todas as páginas, exceto a última
      pdf.repeat(:all, dynamic: true) do
        unless pdf.page_number == pdf.page_count
          # 50 px de largura, 30 px acima do rodapé
          pdf.image ruprica_image, width: 50, at: [pdf.bounds.right - 50, pdf.bounds.bottom + 30]
        end
      end

      # Se o cursor estiver muito baixo, cria nova página para não cortar a assinatura
      pdf.start_new_page if pdf.cursor < 150

      pdf.move_down 10
      # Desenha a assinatura ACIMA da linha
      pdf.image assinatura_image, width: 150, position: :center
      pdf.move_down 10

      pdf.text "_________________________", align: :center
      pdf.text "Assinatura do Fornecedor", align: :center
    else
      # Não usar assinatura. Apenas exibe espaço + linha
      pdf.move_down 40
      pdf.text "_________________________", align: :center
      pdf.text "Assinatura do Fornecedor", align: :center
    end

    pdf.render
  end
end
