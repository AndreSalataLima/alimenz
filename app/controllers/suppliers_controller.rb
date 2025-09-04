class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_supplier

  def home
    @quotation_responses = current_user.quotation_responses
      .includes(:quotation)
      .where.not(quotations: { status: [ "respostas_encerradas", "concluida", "arquivada", "expirada" ] })
      .order(created_at: :desc)

      @purchase_orders = PurchaseOrder
      .where(supplier_id: current_user.id, status: :aberta)
      .order(created_at: :desc)
      end


  private

  def verify_supplier
    redirect_to root_path, alert: "Access denied." unless current_user.role == "supplier"
  end
end
