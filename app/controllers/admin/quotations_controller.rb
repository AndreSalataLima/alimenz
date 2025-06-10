module Admin
  class QuotationsController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_quotation, only: [:show, :encerrar_respostas, :arquivar]


    def index
      @quotations = Quotation.order(created_at: :desc)
    end

    def show
      @quotation = Quotation.find(params[:id])
      @items = @quotation.quotation_items.includes(:product)

      supplier_ids = @quotation
                      .quotation_responses
                      .where(analysis_status: "aprovado")
                      .pluck(:supplier_id)
                      .uniq
      @suppliers = User.where(id: supplier_ids)

      @purchase_orders = @quotation.purchase_orders.order(created_at: :desc)
    end


    def encerrar_respostas
      @quotation.encerrar_para_novas_respostas!
      redirect_to admin_quotation_path(@quotation), notice: "Respostas encerradas com sucesso."
    end

    def arquivar
      @quotation.transaction do
        @quotation.update!(status: "arquivada")
        @quotation.quotation_responses.update_all(status: "arquivada")
        @quotation.purchase_orders.update_all(status: "arquivada")
      end

      redirect_to admin_quotations_path, notice: "Cotação arquivada com sucesso."
    end

    def concluir
      @quotation = Quotation.find(params[:id])
      @quotation.transaction do
        @quotation.update!(status: "concluida")
        @quotation.quotation_responses
                  .where(status: "resposta_aprovada")
                  .update_all(status: "concluida")
      end

      @quotation.update!(status: "concluida")
      redirect_to admin_quotation_path(@quotation), notice: "Cotação marcada como concluída com sucesso."
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
