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
        @quotation_response.update(analysis_status: "aprovado")
        redirect_to admin_dashboard_index_path, notice: "Cotação aprovada e enviada para o cliente."
      else
        redirect_to admin_quotation_response_path(@quotation_response), alert: "Complete todos os itens da checklist para aprovar a cotação."
      end
    end

    def reject
      @quotation_response.update(analysis_status: "cotacao_nao_aceita", status: "pendente")
      redirect_to admin_dashboard_index_path, notice: "Cotação rejeitada. O fornecedor pode reenviar a resposta."
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
