class CotacoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_cliente, only: [:new, :create, :selecionar_pedidos, :resumo_pedidos, :finalizar_pedidos]

  def index
    @cotacoes = current_usuario.cotacoes.order(created_at: :desc)
  end


  def new
    @cotacao = Cotacao.new
    @cotacao.itens_de_cotacao.build
    @produtos = Produto.all
  end

  def show
    @cotacao = Cotacao.find(params[:id])
  end

  def new
    @cotacao = Cotacao.new
    # Prepara ao menos um item para o formulário (pode ser expandido via JavaScript futuramente)
    @cotacao.itens_de_cotacao.build
  end

  def create
    @cotacao = current_usuario.cotacoes.build(cotacao_params)
    if @cotacao.save
      redirect_to @cotacao, notice: "Cotação criada com sucesso."
    else
      puts @cotacao.errors.full_messages
      render :new
    end
  end

  # Passo 4: Exibir a tabela para seleção dos itens com fornecedores
  def selecionar_pedidos
    @cotacao = Cotacao.find(params[:id])
    @itens = @cotacao.itens_de_cotacao.includes(:produto)
    # Carregar os fornecedores que responderam com status "finalizado" para essa cotação
    fornecedores_ids = @cotacao.respostas_de_cotacao.where(status: "finalizado").pluck(:fornecedor_id).uniq
    @fornecedores = Usuario.where(id: fornecedores_ids)
  end

  # Passo 5: Processar a seleção e exibir o resumo agrupado por fornecedor
  def resumo_pedidos
    @cotacao = Cotacao.find(params[:id])
    # "selecionados" agora é um hash onde cada chave é a resposta e o valor é outro hash com item_id => "1"
    selecionados = params[:selecionados] || {}

    # Seleciona as respostas com os IDs enviados
    @respostas_selecionadas = RespostaDeCotacao.where(id: selecionados.keys)

    # Agrupa as respostas por fornecedor
    @respostas_por_fornecedor = @respostas_selecionadas.group_by(&:fornecedor_id)

    # Para cada resposta, filtra apenas os itens que foram selecionados
    @itens_por_resposta = {}
    @respostas_selecionadas.each do |resposta|
      selected_item_ids = selecionados[resposta.id.to_s]&.keys || []
      filtered_items = resposta.resposta_de_cotacao_items.select do |r_item|
        selected_item_ids.include?(r_item.item_de_cotacao.id.to_s)
      end
      @itens_por_resposta[resposta.id] = filtered_items
    end

    # Calcula o valor total para cada fornecedor com base nos itens filtrados
    @resumos = {}
    @respostas_selecionadas.each do |resposta|
      total = @itens_por_resposta[resposta.id].sum do |item|
        item.preco.to_f * item.item_de_cotacao.quantidade.to_f
      end
      @resumos[resposta.fornecedor_id] ||= 0
      @resumos[resposta.fornecedor_id] += total
    end
  end


  # Passo 7: Finalizar e gerar os pedidos de compra para os fornecedores confirmados
  def finalizar_pedidos
    @cotacao = Cotacao.find(params[:id])
    # "selecionados" agora é um hash no formato:
    # { "resposta_id1" => { "item_id_a" => "1", ... }, "resposta_id2" => { "item_id_b" => "1", ... } }
    selecionados = params[:selecionados] || {}
    # Recupera as respostas de cotação selecionadas com base nas chaves do hash
    respostas_selecionadas = RespostaDeCotacao.where(id: selecionados.keys)

    # Filtra os itens de cada resposta conforme os checkboxes selecionados
    itens_por_resposta = {}
    respostas_selecionadas.each do |resposta|
      selected_item_ids = selecionados[resposta.id.to_s]&.keys || []
      filtered_items = resposta.resposta_de_cotacao_items.select do |r_item|
        selected_item_ids.include?(r_item.item_de_cotacao.id.to_s)
      end
      itens_por_resposta[resposta.id] = filtered_items
    end

    # Agrupa as respostas por fornecedor
    respostas_por_fornecedor = respostas_selecionadas.group_by(&:fornecedor_id)
    @pedidos_criados = []

    # "confirmacoes" contém para cada fornecedor_id se o cliente confirmou o pedido ("1")
    confirmacoes = params[:confirmacoes] || {}

    respostas_por_fornecedor.each do |fornecedor_id, respostas|
      next unless confirmacoes[fornecedor_id.to_s] == "1"

      # Para cada resposta desse fornecedor, agregamos apenas os itens filtrados
      itens = []
      respostas.each do |resposta|
        itens.concat(itens_por_resposta[resposta.id])
      end

      # Calcula o valor total apenas com os itens selecionados
      valor_total = itens.sum { |item| item.preco.to_f * item.item_de_cotacao.quantidade.to_f }

      # Cria o Pedido de Compra com os itens formatados (transformando cada item num hash)
      pedido = current_usuario.pedidos_de_compras.create!(
        fornecedor_id: fornecedor_id,
        valor_total: valor_total,
        data_validade: @cotacao.data_validade,
        status: "pendente",
        itens: itens.map do |i|
          {
            produto_id: i.item_de_cotacao.produto_id,
            quantidade: i.item_de_cotacao.quantidade,
            preco: i.preco,
            unidade: i.item_de_cotacao.unidade_selecionada
          }
        end
      )
      @pedidos_criados << pedido
    end

    redirect_to pedidos_de_compras_path, notice: "Pedidos de compra gerados com sucesso."
  end


  private

  def cotacao_params
    params.require(:cotacao).permit(:data_validade, itens_de_cotacao_attributes: [:produto_id, :quantidade, :unidade_selecionada])
  end

  def verificar_cliente
    redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "cliente"
  end
end
