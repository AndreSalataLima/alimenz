module Admin
  class QuotationsController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin

    def index
      @quotations = Quotation.order(created_at: :desc)
    end

    def show
      @quotation = Quotation.find(params[:id])
    end

    private

    def verify_admin
      redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"
    end
  end
end
