module Admin
  class CotacoesController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_admin

    def index
      @cotacoes = Cotacao.order(created_at: :desc)
    end

    def show
      @cotacao = Cotacao.find(params[:id])
    end

    private

    def verificar_admin
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "admin"
    end
  end
end
