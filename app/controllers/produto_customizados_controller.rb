class ProdutoCustomizadosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_cliente

  def create
    @produto = Produto.find(params[:produto_id])
    custom = ProdutoCustomizado.find_or_initialize_by(cliente_id: current_usuario.id, produto_id: @produto.id)
    custom.nome_customizado = params[:nome_customizado]

    if custom.save
      redirect_to @produto, notice: "Nome customizado salvo."
    else
      redirect_to @produto, alert: "Falha ao salvar nome customizado."
    end
  end

  private

  def verificar_cliente
    redirect_to root_path unless current_usuario&.papel == "cliente"
  end
end
