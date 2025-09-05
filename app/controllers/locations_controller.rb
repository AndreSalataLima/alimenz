class LocationsController < ApplicationController
  before_action :authenticate_user!

  def cities
    cities = City.where(state_id: params[:state_id]).order(:name)
    render json: cities.as_json(only: [ :id, :name ])
  end
end
