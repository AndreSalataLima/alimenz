class ApplicationController < ActionController::Base
  include Pagy::Backend


  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    case resource.role
    when "admin"
      admin_dashboard_index_path
    when "supplier"
      supplier_home_path
    when "customer"
      customer_home_path
    else
      root_path
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :name, :role ])
  end
end
