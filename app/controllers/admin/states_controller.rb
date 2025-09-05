module Admin
  class StatesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_state, only: [:edit, :update, :destroy]

    def index
      @states = State.order(:code)
    end

    def new
      @state = State.new
    end

    def create
      @state = State.new(state_params)
      if @state.save
        redirect_to admin_states_path, notice: "Estado criado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @state.update(state_params)
        redirect_to admin_states_path, notice: "Estado atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @state.destroy
      redirect_to admin_states_path, notice: "Estado removido."
    end

    private
    def set_state; @state = State.find(params[:id]); end
    def state_params; params.require(:state).permit(:name, :code); end
    def verify_admin; redirect_to root_path, alert: "Access denied." unless current_user.role == "admin"; end
  end
end
