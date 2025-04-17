class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_customer, only: [ :home ]

  def home
    @quotation = Quotation.new
    @quotation.quotation_items.build
    @categories = Category.order(:name)

    @selected_category = params[:category_id]
    @search_term = params[:search]

    products = Product.all
    products = products.where(category_id: @selected_category) if @selected_category.present?
    products = products.where("generic_name ILIKE ?", "%#{@search_term}%") if @search_term.present?

    @pagy, @products = pagy(products.order(:generic_name), items: 15)
  end

  private

  def verify_customer
    redirect_to root_path, alert: "Access denied." unless current_user.role == "customer"
  end
end
