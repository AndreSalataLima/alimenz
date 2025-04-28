class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_supplier

  def home
    @quotation_responses = current_user.quotation_responses.includes(:quotation).order(created_at: :desc)
    @purchase_orders = PurchaseOrder.where(supplier_id: current_user.id).order(created_at: :desc)
  end

  private

  def verify_supplier
    redirect_to root_path, alert: "Access denied." unless current_user.role == "supplier"
  end
end
