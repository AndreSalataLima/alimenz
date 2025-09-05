module Admin
  class CitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_city, only: [:edit, :update, :destroy]

    def index
      @states = State.order(:code)
      @cities = City.includes(:state).order("states.code asc, cities.name asc")
    end

    def new
      @city = City.new
    end

    def create
      @city = City.new(city_params)
      if @city.save
        redirect_to admin_cities_path, notice: "Cidade criada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @city.update(city_params)
        redirect_to admin_cities_path, notice: "Cidade atualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @city.destroy
      redirect_to admin_cities_path, notice: "Cidade removida."
    end

    private
    def set_city; @city = City.find(params[:id]); end
    def city_params; params.require(:city).permit(:name, :state_id); end
    def verify_admin; redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"; end
  end
end
