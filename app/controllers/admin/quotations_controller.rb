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
      @purchase_order.transaction do
        @purchase_order.update!(status: "arquivada")
        if @purchase_order.quotation.present?
          @purchase_order.quotation.update!(status: "arquivada")

          @purchase_order.quotation.quotation_responses.where.not(status: "concluida").update_all(status: "arquivada")
        end
      end

      redirect_to admin_purchase_order_path(@purchase_order), notice: "Pedido arquivado com sucesso."
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
