class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin

  def index
    # Place any dashboard logic here
  end

  # def pending_verifications
  # Method declared in routes, if needed
  # end

  private

  def verify_admin
    unless current_user && current_user.role == "admin"
      redirect_to root_path, alert: "Access denied."
    end
  end
end
