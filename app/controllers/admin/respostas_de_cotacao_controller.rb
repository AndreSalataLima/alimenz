module Admin
  class RespostasDeCotacaoController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_admin
    before_action :set_resposta, only: [:show, :aprovar, :reprovar]

    def index
      @respostas = RespostaDeCotacao.includes(:cotacao, :fornecedor).order(created_at: :desc)
    end

    def show
      @itens = @resposta.resposta_de_cotacao_items.includes(item_de_cotacao: :produto)
    end

    def aprovar
      checklist = params.slice(:check_carimbo, :check_data, :check_produtos, :check_valores)
      if params[:override] == "1" || checklist.values.all? { |v| v == "1" }
        @resposta.update(status_analise: "aprovado")
        redirect_to admin_dashboard_index_path, notice: "Cotação aprovada e enviada para o cliente."
      else
        redirect_to admin_resposta_de_cotacao_path(@resposta), alert: "Preencha todos os itens do checklist para aprovar a cotação."
      end
    end


    def reprovar
      @resposta.update(status_analise: "cotacao_nao_aceita", status: "pendente")
      redirect_to admin_dashboard_index_path, notice: "Cotação reprovada. O fornecedor poderá reenviar a resposta."
    end

    private

    def set_resposta
      @resposta = RespostaDeCotacao.find(params[:id])
    end

    def verificar_admin
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "admin"
    end
  end
end
