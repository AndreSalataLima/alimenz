module Admin
  class QuotationResponsesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_response, only: [:show, :approve, :reject]

    def index
      @responses = QuotationResponse.includes(:quotation, :supplier).order(created_at: :desc)
    end

    def show
      @items = @response.quotation_response_items.includes(quotation_item: :product)
    end

    def approve
      checklist = params.slice(:check_stamp, :check_date, :check_products, :check_values)
      if params[:override] == "1" || checklist.values.all? { |v| v == "1" }
        @response.update(analysis_status: "approved")
        redirect_to admin_dashboard_index_path, notice: "Quotation approved and sent to the customer."
      else
        redirect_to admin_quotation_response_path(@response), alert: "Please complete all checklist items to approve the quotation."
      end
    end

    def reject
      @response.update(analysis_status: "quotation_not_accepted", status: "pending")
      redirect_to admin_dashboard_index_path, notice: "Quotation rejected. The supplier can resubmit the response."
    end

    private

    def set_response
      @response = QuotationResponse.find(params[:id])
    end

    def verify_admin
      redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"
    end
  end
end
