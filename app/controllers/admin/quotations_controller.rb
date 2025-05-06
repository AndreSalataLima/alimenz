module Admin
  class QuotationsController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_quotation, only: [:show, :liberar_visualizacao, :encerrar_respostas]


    def index
      @quotations = Quotation.order(created_at: :desc)
    end

    def show
      @quotation = Quotation.find(params[:id])
    end

    def liberar_visualizacao
      if @quotation.status.in?(%w[aberta resposta_recebida])
        @quotation.update!(status: 'visualizacao_liberada')

        @quotation.quotation_responses
                  .where(status: 'documento_enviado', analysis_status: 'aprovado')
                  .update_all(status: 'visualizacao_liberada')

        redirect_to admin_quotation_path(@quotation), notice: "Cotação liberada para visualização do cliente."
      else
        redirect_to admin_quotation_path(@quotation), alert: "Status atual não permite liberação."
      end
    end

    def encerrar_respostas
      @quotation.encerrar_para_novas_respostas!
      redirect_to admin_quotation_path(@quotation), notice: "Respostas encerradas com sucesso."
    end

    def arquivar
      @quotation = Quotation.find(params[:id])
      @quotation.update!(status: "arquivada")
      redirect_to admin_quotation_path(@quotation), notice: "Cotação arquivada com sucesso."
    end

    
    private

    def set_quotation
      @quotation = Quotation.find(params[:id])
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user.role == "admin"
    end

  end
end
