class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_customer, only: [ :home ]

  def home
    # Only customers have access to this area
    @quotation = Quotation.new
    @products = Product.order(:generic_name)
  end

  private

  def verify_customer
    redirect_to root_path, alert: "Access denied." unless current_user.role == "customer"
  end
end
