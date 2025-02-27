require "prawn"
require "prawn/table"
require "stringio"

class PdfGeneratorService
  def initialize(resposta, usar_assinatura: false)
    @resposta = resposta
    @usar_assinatura = usar_assinatura
  end

  def generate
    @resposta.reload
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # Cabeçalho – Informações da Proposta de Cotação
    pdf.text "PROPOSTA DE COTAÇÃO", size: 20, style: :bold, align: :center
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    # Dados da Entidade Participante – dados do cliente que criou a cotação
    cliente = @resposta.cotacao.cliente
    entidade_nome  = cliente.nome
    entidade_cnpj  = cliente.cnpj

    # Dados da Empresa Proponente – dados do fornecedor que respondeu à cotação
    fornecedor = @resposta.fornecedor
    empresa_nome       = fornecedor.nome
    empresa_cnpj       = fornecedor.cnpj
    empresa_endereco   = fornecedor.endereco
    empresa_telefone   = fornecedor.telefone
    responsavel        = fornecedor.responsavel
    data_emissao       = Date.today.strftime("%d/%m/%Y")
    validade     = @resposta.cotacao.data_validade.strftime("%d/%m/%Y")

    # Exibe os dados em duas colunas
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Entidade Participante:", style: :bold
      pdf.text entidade_nome
      pdf.text "CNPJ: #{entidade_cnpj}"
    end

    pdf.bounding_box([pdf.bounds.width / 2 + 10, pdf.cursor + 40], width: pdf.bounds.width / 2 - 10) do
      pdf.text "Empresa Proponente:", style: :bold
      pdf.text empresa_nome
      pdf.text "CNPJ: #{empresa_cnpj}"
      pdf.text "Endereço: #{empresa_endereco}"
      pdf.text "Telefone: #{empresa_telefone}"
      pdf.text "Data de emissão: #{data_emissao}"
      pdf.text "Validade: #{validade}"
      pdf.text "Responsável: #{responsavel}"
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Tabela de Cotação de Preços
    table_data = [["ITEM", "QUANT", "UNID", "DESCRIÇÃO", "PREÇO UNI (R$)", "TOTAL (R$)"]]
    item_index = 1
    @resposta.resposta_de_cotacao_items.includes(:item_de_cotacao).each do |item|
      next unless item.disponivel

      cotacao_item = item.item_de_cotacao
      produto      = cotacao_item.produto
      quantidade   = cotacao_item.quantidade
      unidade      = cotacao_item.unidade_selecionada
      descricao    = produto.nome_generico
      preco_uni    = item.preco
      total        = quantidade * preco_uni

      table_data << [
        item_index,
        quantidade,
        unidade,
        descricao,
        "R$ #{'%.2f' % preco_uni}",
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

    # Linha da Assinatura
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      # Rótulo "Assinatura:" à esquerda
      pdf.text "Assinatura:", style: :bold, align: :left

      # Se a assinatura digital estiver disponível, exibe a imagem à direita
      if @usar_assinatura && fornecedor.assinatura&.imagem_assinatura&.attached?
        file = fornecedor.assinatura.imagem_assinatura.download
        assinatura_image = StringIO.open(file)
        # Posiciona a imagem com um deslocamento à direita (ajuste o [x,y] conforme necessário)
        pdf.bounding_box([150, pdf.cursor + 15], width: 150, height: 50) do
          pdf.image assinatura_image, fit: [150, 50]
        end
      end
    end

    pdf.move_down 30

    # Linha do Carimbo da Empresa
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      # Rótulo "Carimbo da empresa:" à esquerda
      pdf.text "Carimbo da empresa:", style: :bold, align: :left

      # Exibe a imagem do carimbo (caso esteja anexada)
      if fornecedor.assinatura&.imagem_carimbo&.attached?
        file = fornecedor.assinatura.imagem_carimbo.download
        carimbo_image = StringIO.open(file)
        pdf.bounding_box([200, pdf.cursor + 15], width: 150, height: 50) do
          pdf.image carimbo_image, fit: [150, 50]
        end
      end
    end

    pdf.move_down 20
    pdf.text "Dados da Empresa:", style: :bold
    pdf.text "Razão Social: #{empresa_nome}"
    pdf.text "CNPJ: #{empresa_cnpj}"
    pdf.text "Endereço: #{empresa_endereco}"
    pdf.text "Telefone: #{empresa_telefone}"

    pdf.render
  end
end
