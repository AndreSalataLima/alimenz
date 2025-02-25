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
    @pedido = PedidoDeCompra.find(params[:id])

    pdf = Prawn::Document.new
    pdf.text "Pedido de Compra ##{@pedido.id}", size: 20, style: :bold
    pdf.text "Cliente: #{@pedido.cliente.nome}"
    pdf.text "Fornecedor: #{@pedido.fornecedor.nome}"
    pdf.text "Data de Validade: #{@pedido.data_validade.strftime('%d/%m/%Y')}" if @pedido.data_validade

    pdf.move_down 20

    data = [["Produto", "Quantidade", "Unidade", "Preço (R$)"]]

    @pedido.itens.each do |item|
      produto = Produto.find(item["produto_id"])
      data << [
        produto.nome_generico,
        item["quantidade"],
        item["unidade"],
        "R$ #{item['preco']}"
      ]
    end

    pdf.table(data, header: true, cell_style: { padding: 5 })

    send_data pdf.render,
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
