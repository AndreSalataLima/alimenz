class CotacoesController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_cliente, only: [:new, :create]

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

  private

  def cotacao_params
    params.require(:cotacao).permit(:data_validade, itens_de_cotacao_attributes: [:produto_id, :quantidade, :unidade_selecionada])
  end

  def verificar_cliente
    redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "cliente"
  end
end
