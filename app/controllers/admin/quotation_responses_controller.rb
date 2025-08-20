module Admin
  class QuotationResponsesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_response, only: [:show, :approve, :reject]

    def index
      @quotation_responses = QuotationResponse.includes(:quotation, :supplier).order(created_at: :desc)
    end

    def show
      @quotation_response = QuotationResponse.find(params[:id])
      @items = @quotation_response.quotation_response_items.includes(quotation_item: :product)
    end

    def approve
      checklist = params.slice(:check_carimbo, :check_data, :check_produtos, :check_valores)

      if params[:override] == "1" || checklist.values.all? { |v| v == "1" }
        @quotation_response.update(analysis_status: "aprovado", status: "resposta_aprovada")
        redirect_to admin_dashboard_index_path, notice: "Cotação aprovada e enviada para o cliente."
      else
        redirect_to admin_quotation_response_path(@quotation_response), alert: "Complete todos os itens da checklist para aprovar a cotação."
      end
    end

    def reject
      feedback = params[:admin_feedback]
      @quotation_response.update!(
        analysis_status: "reprovado",
        status: "revisao_fornecedor",
        admin_feedback: feedback
      )
      redirect_to admin_dashboard_index_path, notice: "Cotação rejeitada. O fornecedor poderá reenviar a resposta."
    end

    def revert_approval
      @quotation_response = QuotationResponse.find(params[:id])

      if @quotation_response.status == "resposta_aprovada" && @quotation_response.analysis_status == "aprovado"
        @quotation_response.update!(
          status: "revisao_fornecedor",
          analysis_status: "reprovado",
          admin_feedback: ""
        )
        redirect_to admin_quotation_response_path(@quotation_response), notice: "Resposta revertida para revisão do fornecedor."
      else
        redirect_to admin_quotation_response_path(@quotation_response), alert: "A resposta não está em um estado válido para reversão."
      end
    end

    private

    def set_response
      @quotation_response = QuotationResponse.find(params[:id])
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user.role == "admin"
    end
  end
end
