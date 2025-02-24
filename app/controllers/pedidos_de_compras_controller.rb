class PedidosDeComprasController < ApplicationController
  before_action :authenticate_usuario!

  # Lista os pedidos de compra do cliente atual
  def index
    @pedidos = current_usuario.pedidos_de_compras.includes(:fornecedor).order(created_at: :desc)
  end

  # Exibe os detalhes de um pedido de compra
  def show
    @pedido = PedidoDeCompra.find(params[:id])
    # Opcional: Verificar se o pedido pertence ao current_usuario
    redirect_to pedidos_de_compras_path, alert: "Acesso negado." unless @pedido.cliente == current_usuario
  end

  # Tela para revisão e confirmação do pedido
  def new
    @pedido = PedidoDeCompra.new
    # Supondo que você obtenha os dados para o pedido a partir das respostas de cotação finalizadas do cliente.
    # Exemplo: Agrupar fornecedores a partir das respostas finalizadas.
    @fornecedores = current_usuario.respostas_de_cotacao.where(status: "finalizado").map(&:fornecedor).uniq

    # Também prepare um resumo dos itens (essa lógica pode vir de um serviço ou do próprio controller)
    # Aqui, @itens é um array de hashes com chaves: nome, quantidade, unidade, preco.
    # Essa parte deve ser ajustada conforme a forma como você coleta os itens aprovados.
    @itens = [] # Exemplo: current_usuario.cotacoes.last.respostas_de_cotacao.first.resposta_de_cotacao_items.map { |i| { "nome" => i.item_de_cotacao.produto.nome_generico, "quantidade" => i.item_de_cotacao.quantidade, "unidade" => i.item_de_cotacao.unidade_selecionada, "preco" => i.preco } }

    # Para facilitar, vamos supor que a data de validade será a mesma da última cotação do cliente
    ultima_cotacao = current_usuario.cotacoes.last
    @pedido.data_validade = ultima_cotacao.data_validade if ultima_cotacao
  end

  # Cria o pedido de compra a partir dos dados enviados
  def create
    @pedido = current_usuario.pedidos_de_compras.build(pedido_de_compra_params)
    if @pedido.save
      redirect_to @pedido, notice: "Pedido de compra gerado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def pedido_de_compra_params
    params.require(:pedido_de_compra).permit(:fornecedor_id, :valor_total, :data_validade, :status, itens: {})
  end
end
