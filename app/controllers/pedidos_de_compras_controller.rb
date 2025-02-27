class PedidosDeComprasController < ApplicationController
  before_action :authenticate_usuario!

  # Lista os pedidos de compra do cliente atual
  def index
    if current_usuario.papel == "fornecedor"
      @pedidos = PedidoDeCompra.where(fornecedor_id: current_usuario.id).order(created_at: :desc)
    else
      @pedidos = PedidoDeCompra.where(cliente_id: current_usuario.id).order(created_at: :desc)
    end
  end

  # Exibe os detalhes de um pedido de compra
  def show
    @pedido = PedidoDeCompra.find(params[:id])
    # Opcional: Verificar se o pedido pertence ao current_usuario
    redirect_to pedidos_de_compras_path, alert: "Acesso negado." unless @pedido.cliente == current_usuario
  end

  # Tela para revisão e confirmação do pedido
  def new
    @pedido = current_usuario.pedidos_de_compras.build
    @fornecedores = current_usuario.respostas_de_cotacao
                                   .where(status: "finalizado")
                                   .map(&:fornecedor).uniq

    # Se quiser pré-popular alguns itens, você pode fazer:
    # @pedido.pedido_de_compra_items.build(...)
  end

  def create
    @pedido = current_usuario.pedidos_de_compras.build(pedido_de_compra_params)
    if @pedido.save
      redirect_to @pedido, notice: "Pedido de compra gerado com sucesso."
    else
      @fornecedores = current_usuario.respostas_de_cotacao
                                     .where(status: 'finalizado').map(&:fornecedor).uniq
      render :new, status: :unprocessable_entity
    end
  end

  def pdf
    @pedido = PedidoDeCompra.includes(:pedido_de_compra_items).find(params[:id])

    puts "Verificando pedido antes de gerar PDF"
    puts "Pedido ID: #{@pedido.id}, Cliente: #{@pedido.cliente.nome}, Fornecedor: #{@pedido.fornecedor.nome}"
    @pedido.pedido_de_compra_items.each do |item|
      puts "Item: #{item.produto.nome_generico}, Quantidade: #{item.quantidade}, Preço: #{item.preco}"
    end

    pdf = PdfPedidoCompraService.new(@pedido).generate

    send_data pdf,
              filename: "pedido_de_compra_#{@pedido.id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end




  private

  def pedido_de_compra_params
    params.require(:pedido_de_compra).permit(
      :fornecedor_id, :valor_total, :data_validade, :status,
      pedido_de_compra_items_attributes: [:produto_id, :quantidade, :unidade, :preco, :_destroy]
    )
  end
end
