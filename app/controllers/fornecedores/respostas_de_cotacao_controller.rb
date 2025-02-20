module Fornecedores
  class RespostasDeCotacaoController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_fornecedor

    def index
      # Lista as respostas de cotação associadas ao fornecedor logado.
      @respostas = current_usuario.respostas_de_cotacao.includes(:cotacao)
    end

    def show
      @resposta = RespostaDeCotacao.find(params[:id])
    end

    private

    def verificar_fornecedor
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "fornecedor"
    end
  end
end
