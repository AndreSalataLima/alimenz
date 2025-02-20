# app/controllers/clientes_controller.rb
class ClientesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_cliente, only: [:home]

  def home
    # Apenas clientes têm acesso a esta área
    @cotacao = Cotacao.new
    @produtos = Produto.order(:nome_generico)
  end

  private

  def verificar_cliente
    redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "cliente"
  end
end
