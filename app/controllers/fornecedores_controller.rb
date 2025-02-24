class FornecedoresController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_fornecedor

  def home
    @respostas = current_usuario.respostas_de_cotacao.includes(:cotacao)
    @pedidos = PedidoDeCompra.where(fornecedor_id: current_usuario.id).order(created_at: :desc)

  end

  private

  def verificar_fornecedor
    redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "fornecedor"
  end

end
